# System Patterns: Dotfiles Repository

## System Architecture

### Overall Architecture

The dotfiles repository follows a modular architecture organized around application-specific configurations. It uses chezmoi as the underlying management system, which provides templating, secure handling of sensitive data, and cross-platform compatibility.

```
dotfiles (repository)
├── chezmoi configuration
├── shell configurations
├── editor configurations
├── git configurations
├── terminal configurations
├── utility configurations
└── system-specific configurations
```

### Key Components

#### Chezmoi Source Structure

The repository follows the standard chezmoi source directory structure:

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl    # Chezmoi configuration template
├── dot_config/           # Files that map to ~/.config/
│   ├── fish/             # Fish shell configuration
│   ├── nvim/             # Neovim configuration
│   └── ...               # Other application configs
├── dot_gitconfig.tmpl    # Template for .gitconfig
├── private_dot_ssh/      # SSH configuration (marked private)
├── run_once_install.sh   # Scripts that run on first install
└── ...
```

#### Source State Mapping

Chezmoi maps source files to their target locations using specific naming conventions:

* `dot_` prefix: Maps to a dotfile in the home directory
* `private_` prefix: File with restrictive permissions
* `executable_` prefix: File with executable permissions
* `.tmpl` suffix: Template file processed with text/template
* `run_once_` prefix: Scripts that run once on installation
* `run_` prefix: Scripts that run on every update

## Design Patterns

### Configuration Management Patterns

#### Template Pattern

Template files (`.tmpl` suffix) allow for dynamic configuration generation based on:

* Operating system detection
* Host-specific configurations
* Environment variables
* External data sources
* User input during setup

#### Layered Configuration

Configurations are structured in layers:

1. **Base layer**: Default configurations suitable for all systems
2. **OS-specific layer**: Adaptations for specific operating systems
3. **Machine-specific layer**: Host-specific customizations
4. **Local overrides**: User-specific changes not tracked in the repository

#### Feature Toggles

Configurations use conditional logic to enable/disable features based on:

* Available system commands
* Operating system capabilities
* User preferences
* Machine role (personal, work, server)

### Deployment Patterns

#### Idempotent Operations

All configuration scripts and operations are designed to be idempotent—running them multiple times produces the same result without unintended side effects.

#### Progressive Enhancement

Configurations start with sensible defaults and progressively enhance functionality based on available tools and capabilities of the target system.

#### Graceful Degradation

When advanced features are not available on a system, configurations gracefully fall back to simpler alternatives rather than breaking.

## Component Relationships

### Shell and Environment Integration

```
┌─────────────────┐      ┌────────────────┐
│ Shell Config    │──────▶ Environment    │
│ (fish, bash)    │      │ Variables      │
└─────────────────┘      └────────────────┘
        │                        │
        ▼                        ▼
┌─────────────────┐      ┌────────────────┐
│ Shell Functions │      │ Path           │
│ & Aliases       │      │ Configuration  │
└─────────────────┘      └────────────────┘
        │                        │
        └────────────┬───────────┘
                     ▼
             ┌────────────────┐
             │ Applications & │
             │ Utilities      │
             └────────────────┘
```

### Configuration Flow

```
┌─────────────────┐      ┌────────────────┐      ┌────────────────┐
│ Source Files    │──────▶ Chezmoi        │──────▶ Target Files   │
│ (Repository)    │      │ Processing     │      │ (Home Dir)     │
└─────────────────┘      └────────────────┘      └────────────────┘
                                │
                  ┌─────────────┴──────────┐
                  ▼                        ▼
         ┌────────────────┐      ┌────────────────┐
         │ Templates      │      │ Scripts        │
         │ Processing     │      │ Execution      │
         └────────────────┘      └────────────────┘
```

## Critical Implementation Paths

### Initial Setup Path

1. Repository cloning
2. Chezmoi installation (if not present)
3. Initial configuration generation
4. Template rendering
5. File deployment to appropriate locations
6. Permission settings
7. First-run script execution
8. Dependency installation (if configured)
9. Shell reloading or system restarting (if required)

### Update Path

1. Repository pulling latest changes
2. Differential configuration analysis
3. Template re-rendering (if needed)
4. File updates deployment
5. Update script execution
6. Configuration reloading (where possible without restart)

### Customization Path

1. Local changes to configurations
2. Testing changes
3. Committing changes to repository
4. Pushing to remote repository
5. Pulling changes on other systems
6. Applying updates across systems

## Technical Decisions

### Key Decision: Using Chezmoi

**Context:** Need for a reliable, cross-platform dotfile management system.

**Decision:** Use chezmoi as the primary dotfile manager.

**Rationale:**

* Provides powerful templating capabilities
* Handles sensitive data securely
* Works across multiple platforms
* Supports both simple and complex configurations
* Active development and community
* Built-in handling of different file types and permissions

### Key Decision: Modular Configuration Structure

**Context:** Need to manage multiple tools and applications with different configuration requirements.

**Decision:** Organize configurations modularly by application/tool.

**Rationale:**

* Easier maintenance and updates
* Better separation of concerns
* Allows for selective application of configurations
* Improves readability and organization
* Facilitates troubleshooting

### Key Decision: Template-based Configurations

**Context:** Need to support multiple environments and machines with similar but not identical configurations.

**Decision:** Use templating for environment-specific configurations.

**Rationale:**

* Avoids duplication across different systems
* Centralizes configuration logic
* Allows for dynamic adaptation to different environments
* Maintains a single source of truth for configurations

### Key Decision: Security-Conscious Design

**Context:** Some configurations contain sensitive information that should not be exposed in a public repository.

**Decision:** Use chezmoi's encryption capabilities and private file designations.

**Rationale:**

* Protects sensitive information
* Allows for secure sharing of configurations
* Provides clear marking of private vs. public configurations
* Integrates with established encryption tools

## Architectural Quality Attributes

### Maintainability

* Modular organization facilitates targeted updates
* Clear separation between different tool configurations
* Documentation of non-obvious configuration choices
* Consistent naming and organization patterns

### Adaptability

* Template-based approach adapts to different environments
* OS-detection mechanisms for platform-specific settings
* Feature toggles for different capability sets
* External data integration for dynamic configurations

### Reliability

* Idempotent operations prevent cumulative errors
* Graceful degradation when optimal tools aren't available
* Version control provides rollback capabilities
* Testing mechanisms for configuration validation

### Security

* Private file handling for sensitive information
* Encryption support for critical credentials
* Appropriate file permissions enforcement
* Exclusion patterns for sensitive data

### Usability

* Simple commands for common operations
* Clear documentation for manual steps
* Feedback mechanisms during configuration application
* Intuitive organization reflecting user mental model

## Implementation Guidelines

### Source File Organization

* Group files by application or logical function
* Use chezmoi's naming conventions consistently
* Keep template logic simple and readable
* Document complex templates or scripts

### Script Development

* Prioritize cross-platform compatibility where possible
* Include clear error messages and status reporting
* Implement proper error handling and exit codes
* Document required dependencies

### Template Design

* Keep templates focused on a single responsibility
* Avoid overly complex conditional logic
* Document the variables and conditions used
* Include sensible defaults for all configurable values

### Security Practices

* Never commit plain-text secrets or keys
* Use chezmoi's encryption for sensitive data
* Review public repositories for accidentally committed secrets
* Use appropriate file permissions for sensitive files
