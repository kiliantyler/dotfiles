import base64
import importlib.util
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / ".github/scripts/hindsight-cli.py"
spec = importlib.util.spec_from_file_location("hindsight_cli_update", SCRIPT)
update = importlib.util.module_from_spec(spec)
spec.loader.exec_module(update)


class HindsightCliPinTest(unittest.TestCase):
    def test_major_release_keeps_servicing_the_installed_series(self):
        def release(tag, **kwargs):
            return {"tag_name": tag, "draft": False, "prerelease": False, **kwargs}

        latest = release("v2.0.0")
        pages = [[latest, release("v1.12.0-rc.1", prerelease=True), release("v1.11.0", draft=True)],
                 [release("agent-v8.0.0"), release("v1.10.0"), release("v1.9.0")]]
        with patch.object(update, "gh", side_effect=[latest, pages]):
            self.assertEqual(update.candidate("1.8.0"), "1.10.0")

    def test_publish_changes_only_verified_pin_and_fences_commit(self):
        with tempfile.TemporaryDirectory() as tmp:
            pin = Path(tmp) / "config.toml.tmpl"
            content = 'other = "1.2.0"\n"github:vectorize-io/hindsight" = { version = "1.2.0", rename_exe = "hindsight" }\n'
            pin.write_text(content)
            env = {"VERIFIED_VERSION": "1.3.0", "GITHUB_SHA": "fixture-sha",
                   "GITHUB_REPOSITORY": "test/dotfiles", "DEFAULT_BRANCH": "main"}
            with (patch.object(update, "PIN", pin), patch.dict(os.environ, env),
                  patch("sys.argv", ["update", "publish"]),
                  patch.object(update, "candidate", return_value="1.3.0"),
                  patch.object(update, "gh", return_value={"data": {"createCommitOnBranch": {"commit": {"oid": "new"}}}}) as api):
                update.main()
                change = json.loads(api.call_args.kwargs["input_data"])["variables"]["input"]
                self.assertEqual(change["expectedHeadOid"], "fixture-sha")
                [addition] = change["fileChanges"]["additions"]
                self.assertEqual(addition["path"], str(pin))
                self.assertEqual(base64.b64decode(addition["contents"]).decode(),
                                 content.replace('version = "1.2.0"', 'version = "1.3.0"'))
                os.environ["VERIFIED_VERSION"] = "1.2.1"
                with self.assertRaises(ValueError):
                    update.main()
                self.assertEqual(api.call_count, 1)
