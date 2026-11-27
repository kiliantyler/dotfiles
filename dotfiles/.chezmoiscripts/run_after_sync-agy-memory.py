#!/usr/bin/env python3
"""Register the installed memory hooks in T3's personal Antigravity profiles."""
import json
import os
from pathlib import Path
from tempfile import NamedTemporaryFile


def sync(home):
    source = home / ".gemini/config/hooks.json"
    if not source.is_file():
        return
    hooks = json.loads(source.read_text()).get("coding-agents")

    profiles = home / ".t3/userdata/providers/antigravity"
    for rules in profiles.glob("*/GEMINI.md"):
        if not rules.is_symlink() or rules.resolve() != (home / ".gemini/GEMINI.md").resolve():
            continue
        target = rules.parent / "config/hooks.json"
        if target.is_symlink() or not target.parent.is_dir():
            continue
        profile_hooks = json.loads(target.read_text()) if target.exists() else {}
        owned = profile_hooks.get("coding-agents")
        if owned == hooks:
            continue
        if owned is not None and "/.hindsight/coding-agents/dist/" not in json.dumps(owned):
            continue
        if hooks:
            profile_hooks["coding-agents"] = hooks
        else:
            del profile_hooks["coding-agents"]
        with NamedTemporaryFile(mode="w", dir=target.parent, delete=False) as handle:
            json.dump(profile_hooks, handle, indent=2)
            handle.write("\n")
        os.replace(handle.name, target)


if __name__ == "__main__":
    sync(Path.home())
