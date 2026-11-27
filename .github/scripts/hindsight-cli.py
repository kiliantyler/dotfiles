"""Verify the stable Hindsight CLI release and advance only its existing mise pin."""
import base64
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys
import tempfile
import urllib.request

PIN = Path("dotfiles/private_dot_config/mise/config.toml.tmpl")
RELEASES = "repos/vectorize-io/hindsight/releases"
SEMVER = r"[0-9]+\.[0-9]+\.[0-9]+"
PIN_PATTERN = re.compile(r'^("github:vectorize-io/hindsight" = \{ version = ")(' + SEMVER + r')(")', re.M)


def gh(*args, input_data=None):
    return json.loads(subprocess.check_output(["gh", "api", *args], input=input_data))


def parts(version):
    return tuple(map(int, version.split(".")))


def candidate(current):
    release = gh(RELEASES + "/latest")
    tag = release["tag_name"].removeprefix("v")
    if not (re.fullmatch(SEMVER, tag) and not release["draft"] and not release["prerelease"]):
        raise ValueError("Unexpected latest Hindsight release")
    if parts(tag)[0] > parts(current)[0]:
        print(f"::warning::Hindsight {tag} needs major-version review")
        pages = gh("--paginate", "--slurp", RELEASES + "?per_page=100")
        allowed = [r["tag_name"][1:] for page in pages for r in page
                   if not r["draft"] and not r["prerelease"] and re.fullmatch("v" + SEMVER, r["tag_name"])
                   and parts(r["tag_name"][1:])[0] == parts(current)[0]]
        return max([current, *allowed], key=parts)
    return max(current, tag, key=parts)


def verify(version):
    release = gh(RELEASES + "/tags/v" + version)
    assets = {a["name"]: a for a in release["assets"]}
    names = {"arm64": "hindsight-darwin-arm64", "x86_64": "hindsight-darwin-amd64"}
    with tempfile.TemporaryDirectory() as tmp:
        for arch, name in names.items():
            asset = assets[name]
            url = f"https://github.com/vectorize-io/hindsight/releases/download/v{version}/{name}"
            if asset["browser_download_url"] != url:
                raise ValueError("Unexpected release asset URL")
            with urllib.request.urlopen(url, timeout=60) as response:
                data = response.read()
            if "sha256:" + hashlib.sha256(data).hexdigest() != asset.get("digest"):
                raise ValueError(f"Digest mismatch for {name}")
            if arch == platform.machine() and sys.platform == "darwin":
                exe = Path(tmp) / "hindsight"
                exe.write_bytes(data)
                exe.chmod(0o700)
                env = {"PATH": os.defpath, "HOME": tmp}
                reported = subprocess.check_output([exe, "--version"], env=env, text=True).strip()
                if reported != "hindsight " + version:
                    raise ValueError(f"Unexpected CLI version: {reported}")
                for action, flag in [("retain", "--doc-id"), ("recall", "--budget")]:
                    help_text = subprocess.check_output([exe, "memory", action, "--help"], env=env, text=True)
                    if flag not in help_text:
                        raise ValueError(f"Missing {action} {flag}")
        if not (Path(tmp) / "hindsight").is_file():
            raise RuntimeError("Native verification requires a Mac runner")


def main():
    original = PIN.read_text()
    [(_, current, _)] = PIN_PATTERN.findall(original)
    version = candidate(current)
    if sys.argv[1:] == ["verify"]:
        verify(version)
        print(f"Verified both Darwin asset digests and native CLI {version}; current pin {current}")
        if os.environ.get("GITHUB_OUTPUT"):
            with open(os.environ["GITHUB_OUTPUT"], "a") as output:
                print(f"version={version}", f"changed={str(version != current).lower()}", sep="\n", file=output)
        return
    if sys.argv[1:] != ["publish"] or os.environ["VERIFIED_VERSION"] != version:
        raise ValueError("Verified release no longer matches the eligible release")
    if version == current:
        return
    content = PIN_PATTERN.sub(lambda m: m[1] + version + m[3], original)
    query = """mutation($input: CreateCommitOnBranchInput!) {
      createCommitOnBranch(input: $input) { commit { oid } }
    }"""
    commit = {"branch": {"repositoryNameWithOwner": os.environ["GITHUB_REPOSITORY"],
                         "branchName": os.environ["DEFAULT_BRANCH"]},
              "expectedHeadOid": os.environ["GITHUB_SHA"],
              "message": {"headline": f"chore(deps): update Hindsight CLI to {version}"},
              "fileChanges": {"additions": [{"path": str(PIN), "contents": base64.b64encode(content.encode()).decode()}]}}
    result = gh("graphql", "--input", "-", input_data=json.dumps({"query": query, "variables": {"input": commit}}).encode())
    print("Updated pin:", result["data"]["createCommitOnBranch"]["commit"]["oid"])


if __name__ == "__main__":
    main()
