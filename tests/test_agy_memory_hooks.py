import json
import runpy
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "dotfiles/.chezmoiscripts/run_after_sync-agy-memory.py"


class AntigravityMemoryTest(unittest.TestCase):
    def test_only_the_memory_group_follows_the_personal_profile(self):
        sync = runpy.run_path(str(SCRIPT))["sync"]
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            source = home / ".gemini/config/hooks.json"
            source.parent.mkdir(parents=True)
            group = {"Stop": [{"command": "node /tmp/.hindsight/coding-agents/dist/antigravity-stop-hook.js"}]}
            source.write_text(json.dumps({"coding-agents": group, "personal-only": {}}))
            root = home / ".t3/userdata/providers/antigravity"
            for name in ("personal", "separate"):
                profile = root / name
                (profile / "config").mkdir(parents=True)
                (profile / "GEMINI.md").symlink_to(home / (".gemini/GEMINI.md" if name == "personal" else "other.md"))
                (profile / "config/hooks.json").write_text('{"existing": {}}')

            target = root / "personal/config/hooks.json"
            sync(home)
            self.assertEqual(json.loads(target.read_text()), {"existing": {}, "coding-agents": group})
            self.assertEqual(json.loads((root / "separate/config/hooks.json").read_text()), {"existing": {}})
            source.write_text("{}")
            sync(home)
            self.assertEqual(json.loads(target.read_text()), {"existing": {}})
