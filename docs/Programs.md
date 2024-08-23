
# Programs
| Program                    | Debian     | MacOS      |
|----------------------------|------------|------------|
| 1Password-cli              | asdf       | asdf       |
| nodejs                     | asdf       | asdf       |
| python3                    | asdf       | asdf       |
| fzf                        | asdf       | asdf       |
| kubectl                    | asdf       | asdf       |
| jq                         | asdf       | asdf       |
| zoxide                     | asdf       | asdf       |
| ulauncher                  | apt        | N/A        |
| apt-transport-https        | apt        | N/A        |
| ca-certificates            | apt        | N/A        |
| curl                       | apt        | homebrew?  |
| gnupg                      | apt        | homebrew?  |
| lsb-release                | apt        | N/A        |
| software-properties-common | apt        | N/A        |
| wget                       | apt        | homebrew?  |
| build-essential            | apt        | N/A        |
| git                        | apt        | homebrew?  |
| wmctrl                     | apt        | N/A        |
| ansible                    | TODO       | TODO       |
| zygote                     | czExternal | czExternal |
| asdf                       | czExternal | czExternal |
| kmonad                     | gh-r       | gh-r       |
| font-fira-code-nerd-font   | gh-r       | homebrew   |
| watchman                   | homebrew   | homebrew   |
| zsh                        | TODO       | TODO       |

#### Programs To Add:
- topgrade
- 

### ASDF

<!-- TODO Explain -->

### Apt

<!-- TODO Explain -->

### Github Release (gh-r)

<!-- TODO Explain -->

### Chez Moi External (czExternal)

<!-- TODO Explain -->

### Chez Moi Script (czScript)

- Handles Github Releases*
- Handles Apt*
- Handles asdf*
- Handles Brew*
- Handles Flatpak*
- Handles Snap*

(* indicates this will move to ansible)

### Ansible
 - [Handles APT repos](https://docs.ansible.com/ansible/latest/collections/community/general/apt_repo_module.html)
 - [Will handle Apt Installs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
 - [Will handle asdf](https://github.com/cimon-io/ansible-role-asdf)
 - [Will handle homebrew](https://docs.ansible.com/ansible/latest/collections/community/general/homebrew_module.html)
 - [Will handle cargo?](https://docs.ansible.com/ansible/latest/collections/community/general/cargo_module.html)
 - [Will handle GH-R](https://docs.ansible.com/ansible/latest/collections/community/general/github_release_module.html)
 - [Will handle flatpak](https://docs.ansible.com/ansible/latest/collections/community/general/flatpak_module.html)
 - [Will handle snap](https://docs.ansible.com/ansible/latest/collections/community/general/snap_module.html)

<!--
 TODO: How to install ansible via Chezmoi? 
 pipx? This would require installing pipx and ensuring python3 was good enough
    However python comes on all linux/mac systems
-->

### Flatpak

<!-- TODO Explain -->

### Snap

<!-- TODO Explain -->

