/**
 * Generates a Bash script for macOS and Linux using proper Git URLs
 * @param repoUrl Full Git repository URL (e.g., https://github.com/username/repo.git)
 * @param branch Repository branch to use
 * @returns Complete Bash installation script
 */
export function generateBashScript(repoUrl: string, branch: string): string {
	return `#!/usr/bin/env bash
{
  # -----------------------------------
  # author: @kiliantyler
  # title: Dotfiles Installation Script
  # description: Installs Xcode Command Line Tools if they are not already installed,
  #              then installs Chezmoi and initializes it with dotfiles repo.
  # -----------------------------------

  # -----------------------------------
  # Instructions
  #
  # This script is intended to be run via curl through a specific URL.
  # Do not run this script directly from github.
  #
  # To install, run the following command:
  # curl -fsSL https://install.dotfiles.wiki/?username=yourusername&provider=github | sh
  #
  # Supported providers: github, gitlab, bitbucket, or any custom domain
  # Supports all Git URL formats
  #
  # -----------------------------------

  # POSIX shell script compatible version

  fail() {
    echo "$1" >&2
    exit 1
  }

  # Checks if Command Line Tools are installed (MacOS)
  should_install_command_line_tools() {
    [ ! -e "/Library/Developer/CommandLineTools/usr/bin/git" ]
  }

  # Removes newline from a string (POSIX compatible)
  chomp() {
    echo "$1" | tr -d '\\n'
  }

  sudo -v

  # get OS type
  OS=$(uname -s)

  macos_install() {
    # -----------------------------------
    # Xcode Command Line Tools Installation (MacOS-specific)
    # -----------------------------------
    if should_install_command_line_tools; then
      echo "Installing Xcode Command Line Tools"
      clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
      sudo touch "$clt_placeholder"

      clt_label_command="/usr/sbin/softwareupdate -l |
                        grep -B 1 -E 'Command Line Tools' |
                        awk -F'*' '/^ *\\*/ {print \\$2}' |
                        sed -e 's/^ *Label: //' -e 's/^ *//' |
                        sort -V |
                        tail -n1"
      clt_label="$(chomp "$(sh -c "$clt_label_command")")"

      if [ -n "$clt_label" ]; then
        sudo /usr/sbin/softwareupdate -i "$clt_label"
        sudo /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
      fi
      sudo rm -f "$clt_placeholder"
    fi
  }

  linux_install() {
    # -----------------------------------
    # Linux Dependencies Installation (Linux-specific)
    # -----------------------------------
    if command -v apt-get >/dev/null 2>&1; then
      echo "Installing dependencies with apt-get"
      sudo apt-get update
      sudo apt-get install -y zsh git curl
    elif command -v dnf >/dev/null 2>&1; then
      echo "Installing dependencies with dnf"
      sudo dnf install -y git curl zsh
    elif command -v yum >/dev/null 2>&1; then
      echo "Installing dependencies with yum"
      sudo yum install -y git curl zsh
    else
      fail "Unsupported package manager"
    fi
  }

  if [ "$OS" = "Darwin" ]; then
    echo "MacOS detected"
    macos_install
  elif [ "$OS" = "Linux" ]; then
    echo "Linux detected"
    linux_install
  else
    fail "Unsupported OS: $OS"
  fi

  # -----------------------------------
  # Chezmoi Installation and Initialization
  # -----------------------------------

  if command -v chezmoi >/dev/null 2>&1; then
    echo "Chezmoi is already installed"
  else
    echo "Installing Chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  fi

  # Initialize chezmoi with the provided repo and parameters
  "$HOME/.local/bin/chezmoi" init --apply "${repoUrl}" --branch "${branch}"
}`;
}
