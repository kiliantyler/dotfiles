# Dotfiles Installation Worker

A Cloudflare Worker that serves dynamic installation scripts for dotfiles setup across different operating systems.

## Features

- **Multi-platform Support**: Automatically detects or explicitly specifies the user's operating system (Windows, macOS, Linux)
- **Git Provider Integration**: Support for various Git providers (GitHub, GitLab, Bitbucket, custom domains)
- **Customizable**: Easily adapt for different usernames, repositories, and branches

## Usage

### Basic Usage

For Unix-like systems (macOS/Linux):

```bash
curl -fsSL 'https://install.dotfiles.wiki/' | sh
```

For Windows:

```powershell
iex "&{$(irm 'https://install.dotfiles.wiki/?os=windows')}"
```

### Custom Parameters

You can customize the installation with query parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `username` | Git username | kiliantyler |
| `provider` | Git provider (github, gitlab, bitbucket) | github |
| `branch` | Repository branch | main |
| `repo` | Repository name | dotfiles |
| `os` | Operating system (windows, macos, linux) | auto-detect |

### Examples

#### Specific username with GitHub

```bash
curl -fsSL 'https://install.dotfiles.wiki/?username=johndoe' | sh
```

#### Using GitLab with a specific branch

```bash
curl -fsSL 'https://install.dotfiles.wiki/?provider=gitlab&username=johndoe&branch=develop' | sh
```

#### Windows with specific repo name

```powershell
iex "&{$(irm 'https://install.dotfiles.wiki/?os=windows&username=johndoe&repo=my-config')}"
```

## How It Works

1. The Cloudflare Worker receives a request with query parameters
2. It detects the OS based on the User-Agent or explicit `os` parameter
3. It generates a custom installation script with the appropriate format
4. The script installs any necessary dependencies (e.g., Xcode Command Line Tools on macOS)
5. The script installs [chezmoi](https://www.chezmoi.io/) dotfiles manager
6. chezmoi then initializes with the specified Git repository and branch

## Development

### Prerequisites

- Node.js 16+
- npm or yarn

### Installation

```bash
# Install dependencies
cd cloudflare
bun install
```

### Local Development

```bash
# Start local development server
bun dev
```

### Testing

The project uses a modular testing approach with dedicated test files for different aspects of functionality:

```bash
# Run all tests
bun test

# Run a specific test file
bun test -- test/bash-script.spec.ts
```

The test suite includes:

- Bash script generation tests
- PowerShell script generation tests
- URL generation tests for different Git providers
- Error handling and input validation tests

See [TESTING.md](./TESTING.md) for detailed information about the testing approach.

## License

MIT
