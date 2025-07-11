# Technical Context: Dotfiles Repository

## Core Technologies

### Chezmoi

**Purpose:** Primary dotfile management tool that handles templating, file synchronization, and secure credential management.

**Version:** Latest stable release recommended

**Key Features Used:**

* Source/target state management
* Go text templating
* External program integration
* File encryption support
* Scripting capabilities
* Cross-platform compatibility

**Documentation:** [Chezmoi Documentation](https://www.chezmoi.io/user-guide/command-overview/)

### Git

**Purpose:** Version control system for tracking changes and synchronizing across machines.

**Version:** 2.x+

**Key Features Used:**

* Branching for experimental configurations
* Remote repository synchronization
* History tracking for configuration evolution
* Gitignore patterns for excluding sensitive data
* Git hooks for automation

**Documentation:** [Git Documentation](https://git-scm.com/doc)

### Shell Environments

#### Fish Shell

**Purpose:** Primary interactive shell with enhanced features and user experience.

**Version:** 3.x+

**Key Features Used:**

* Fish functions for custom commands
* Completions for improved CLI experience
* Path configurations
* Environment variable management
* Plugin system via fisher/oh-my-fish

**Documentation:** [Fish Documentation](https://fishshell.com/docs/current/index.html)

#### Bash/ZSH

**Purpose:** Alternative shell support for compatibility and system integration.

**Versions:**

* Bash: 4.x+ preferred, 3.x+ supported
* ZSH: 5.x+

**Key Features Used:**

* Profile scripts (.bashrc, .bash\_profile, .zshrc)
* Environment variable setup
* Path configuration
* Shell functions and aliases

**Documentation:**

* [Bash Documentation](https://www.gnu.org/software/bash/manual/bash.html)
* [ZSH Documentation](https://zsh.sourceforge.io/Doc/)

### Neovim/Vim

**Purpose:** Terminal-based text editors with extensive customization.

**Version:**

* Neovim: 0.5+
* Vim: 8.x+

**Key Features Used:**

* Plugin management
* Custom key mappings
* Editor behaviors and preferences
* Language-specific settings
* Theme configurations

**Documentation:**

* [Neovim Documentation](https://neovim.io/doc/)
* [Vim Documentation](https://www.vim.org/docs.php)

### Visual Studio Code

**Purpose:** Modern code editor with extension support and integrated features.

**Version:** Latest stable

**Key Features Used:**

* Extensions management
* User and workspace settings
* Keybindings customization
* Snippets
* Theme and UI preferences

**Documentation:** [VS Code Documentation](https://code.visualstudio.com/docs)

### Terminal Emulators

**Purpose:** Provide the interface for command-line operations.

**Options:**

* macOS Terminal / iTerm2
* Windows Terminal / ConEmu
* Linux terminal emulators (GNOME Terminal, Konsole, etc.)

**Key Features Used:**

* Color schemes and themes
* Font configurations
* Window/tab management preferences
* Keyboard shortcuts
* Integration with shell environments

## Development Setup

### Required Software

#### Core Requirements

* Git (version control)
* Chezmoi (dotfile management)
* Chosen shell environments (fish, bash, zsh)

#### Additional Tools

* Package managers:
  * Homebrew (macOS)
  * apt, pacman, dnf (Linux distributions)
  * Chocolatey/Winget/Scoop (Windows)
* Terminal multiplexers (e.g., tmux, screen)
* Text editors (Vim, Neovim, VS Code)
* Development utilities (e.g., fzf, ripgrep, fd, bat)

### Setup Process

1. **Clone Repository:**
   ```bash
   git clone https://github.com/kiliantyler/dotfiles.git
   ```

2. **Install Chezmoi:**
   Cross-platform installation options:
   ```bash
   # Linux/macOS
   sh -c "$(curl -fsLS get.chezmoi.io)"

   # Windows PowerShell
   (irm -useb get.chezmoi.io/ps1) | powershell -c -
   ```

3. **Initialize Chezmoi with Repository:**
   ```bash
   chezmoi init --apply https://github.com/kiliantyler/dotfiles.git
   ```

4. **Apply Configuration:**
   ```bash
   chezmoi apply
   ```

### Development Workflow

1. **Make Changes:**
   * Edit source files in `~/.local/share/chezmoi/`
   * Test changes locally

2. **Apply Changes:**
   ```bash
   chezmoi apply
   ```

3. **Commit and Push:**
   ```bash
   chezmoi cd
   git add .
   git commit -m "Description of changes"
   git push
   ```

4. **Update on Other Machines:**
   ```bash
   chezmoi update
   ```

## Technical Constraints

### Cross-Platform Compatibility

**Challenge:** Maintaining consistent configurations across different operating systems (macOS, Linux variants, potentially Windows).

**Solution:**

* Use chezmoi's templating to conditionally apply configurations
* Organize platform-specific configurations separately
* Test on multiple platforms before major changes
* Document platform-specific differences

**Example:**

```
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific configuration
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific configuration
{{- else if eq .chezmoi.os "windows" }}
# Windows-specific configuration
{{- end }}
```

### Security Considerations

**Challenge:** Storing sensitive information (API keys, passwords, tokens) securely.

**Solution:**

* Use chezmoi's integration with password managers or encryption
* Mark sensitive files as private
* Use template functions to retrieve secrets at runtime
* Maintain proper .gitignore patterns

**Example:**

```
{{- onepasswordDocument "aws_credentials" }}
```

### Tool Availability

**Challenge:** Not all tools may be available on all systems or may have different versions.

**Solution:**

* Include installation scripts for common dependencies
* Check for tool existence before using in configurations
* Provide fallback mechanisms for missing tools
* Document minimum version requirements

### Configuration Portability

**Challenge:** Some applications store configurations in different locations across platforms.

**Solution:**

* Use chezmoi's template system to target appropriate paths
* Create symlinks where necessary
* Document manual steps when automation isn't feasible
* Test configuration application on supported platforms

## Dependencies

### External Tools

#### Package Managers

* **Homebrew** (macOS)
* **apt/dnf/pacman** (Linux)
* **Chocolatey/Scoop/Winget** (Windows)

#### Shell Enhancements

* **Fisher/Oh My Fish** (Fish shell plugin manager)
* **Oh My Zsh/Prezto/Zinit** (ZSH enhancements)
* **Starship** (Cross-shell prompt)

#### Terminal Utilities

* **fzf** (Fuzzy finder)
* **ripgrep/fd** (Modern search tools)
* **bat/exa/lsd** (Enhanced replacements for cat/ls)
* **tmux/screen** (Terminal multiplexers)
* **git-delta** (Improved git diff)

#### Development Tools

* **Node.js/npm** (JavaScript development)
* **Python/pip** (Python development)
* **Ruby/gem** (Ruby development)
* **Go** (Go development)
* **Rust/Cargo** (Rust development)

### Configuration Interdependencies

#### Shell and Environment

* Shell configurations depend on environment variables
* Path configurations depend on installed tools
* Prompt customizations depend on specific utilities (e.g., Starship)

#### Editor and IDE

* Vim/Neovim configurations depend on plugin managers
* VS Code depends on extension availability
* Editor themes depend on font installations

#### Git Integration

* Git configurations depend on external diff/merge tools
* SSH key setup required for authentication
* Git hooks depend on specific toolchains

### Versioning Requirements

* **Git:** 2.x+
* **Chezmoi:** Latest stable
* **Fish:** 3.x+
* **Bash:** 4.x+ (3.x+ supported with limitations)
* **ZSH:** 5.x+
* **Neovim:** 0.5+
* **VS Code:** Latest stable recommended

## Tool Usage Patterns

### Chezmoi Patterns

#### Configuration Application

```bash
# Apply all changes
chezmoi apply

# Apply specific files
chezmoi apply ~/.bashrc

# Apply with verbosity
chezmoi apply -v
```

#### Update Workflow

```bash
# Update from source repository
chezmoi update

# Pull changes but don't apply
chezmoi git pull -- --rebase
chezmoi diff  # Review changes
chezmoi apply
```

#### Template Usage

```
# OS-based conditions
{{- if eq .chezmoi.os "darwin" }}
# macOS configuration
{{- end }}

# Host-based conditions
{{- if eq .chezmoi.hostname "work-laptop" }}
# Work-specific configuration
{{- end }}

# External data
{{- $githubData := (index (fromJson (include "git-config-github.json")) 0) }}
```

### Shell Environment Patterns

#### Configuration Organization

```
~/.config/fish/
├── config.fish          # Main configuration
├── conf.d/              # Auto-loaded configs
│   ├── aliases.fish     # Command aliases
│   ├── exports.fish     # Environment variables
│   └── functions.fish   # Function definitions
└── functions/           # Individual function files
    ├── update.fish
    └── ...
```

#### Common Functions

* System update scripts
* Development environment setup
* Configuration reload
* Utility functions for common tasks

### Git Workflow Patterns

* Feature branches for experimental configurations
* Main branch for stable configurations
* Commit hooks for validation
* Structured commit messages

### Installation Patterns

* Bootstrap scripts for new machines
* Dependency checking before installation
* Idempotent installations (can run multiple times)
* Configuration validation after installation

## Additional Technical Details

### Font Requirements

* Programming fonts with ligature support
* Patched fonts for terminal icons (Nerd Fonts)
* Consistent font usage across editors and terminals

### Theme Consistency

* Dark/light theme switching support
* Color scheme coordination across applications
* Terminal color scheme definitions

### Accessibility Considerations

* Configurable font sizes
* High contrast options where supported
* Keyboard navigation enhancements

### Performance Optimizations

* Shell startup time optimization
* Lazy-loading for intensive operations
* Conditional loading of features based on system capabilities

## Technical Documentation Resources

* [Chezmoi User Guide](https://www.chezmoi.io/user-guide/command-overview/)
* [Git Documentation](https://git-scm.com/doc)
* [Fish Shell Documentation](https://fishshell.com/docs/current/)
* [Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
* [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
* [Neovim Documentation](https://neovim.io/doc/)
* [VS Code Documentation](https://code.visualstudio.com/docs)
* [Homebrew Documentation](https://docs.brew.sh/)
