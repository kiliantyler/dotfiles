import json
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "dotfiles/dot_agents/hooks/executable_hindsight-repo"


class RepositoryEnrollmentTest(unittest.TestCase):
    def test_linked_worktree_shares_its_repo_bank_and_forks_remain_separate(self):
        enroll = runpy.run_path(str(SCRIPT))["enroll"]
        with tempfile.TemporaryDirectory() as tmp, patch.dict("os.environ", {"HINDSIGHT_CONFIG": ""}):
            home = Path(tmp).resolve()
            directory = home / ".hindsight"
            directory.mkdir()
            config = directory / "coding-agent.json"
            config.write_text(json.dumps({"optInOnly": True, "apiToken": "synthetic"}))
            (directory / "auto-enroll-repositories").touch()
            def git(*args):
                subprocess.run(["git", *map(str, args)], capture_output=True, check=True)

            first = home / "one/tool"
            second = home / "two/tool"
            private = home / ".private/tool"
            for repo in (first, second, private):
                repo.parent.mkdir()
                git("init", "-q", repo)
                git("-C", repo, "remote", "add", "origin", f"https://example.invalid/{repo.parent.name}/tool.git")
            git("-C", first, "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                "-c", "commit.gpgsign=false", "commit", "--allow-empty", "-qm", "initial")
            linked = home / "separate-worktree"
            git("-C", first, "worktree", "add", "--detach", linked)

            for cwd in (first, linked, second, home, private):
                enroll(cwd, home)
            stored = json.loads(config.read_text())
            self.assertEqual(set(stored["mapPathToBank"]), {str(first), str(second)})
            self.assertNotEqual(*stored["mapPathToBank"].values())
            self.assertEqual(stored["apiToken"], "synthetic")
            self.assertEqual(config.stat().st_mode & 0o777, 0o600)
