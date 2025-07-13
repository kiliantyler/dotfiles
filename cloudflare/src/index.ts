/**
 * Dotfiles Installation Script Worker
 *
 * This Cloudflare Worker generates installation scripts for dotfiles setup.
 * It supports multiple operating systems, Git providers, and branches.
 *
 * Query Parameters:
 * - username: GitHub/GitLab/etc. username (default: kiliantyler)
 * - provider: Git provider (github, gitlab, bitbucket, etc.) (default: github)
 * - branch: Repository branch (default: main)
 * - repo: Repository name (default: dotfiles)
 * - os: Operating system (windows, macos, linux) (default: auto-detect from user-agent)
 *
 * Example usage:
 * curl -fsSL https://install.dotfiles.wiki/?username=johndoe&provider=gitlab&branch=develop | sh
 */

// Import script generators and types
import { generateBashScript } from './scripts/bash-script';
import { generatePowershellScript } from './scripts/powershell-script';
import { ScriptOptions, ScriptType, getRepositoryUrl } from './types';

addEventListener('fetch', (event) => {
	event.respondWith(handleRequest(event.request));
});

async function handleRequest(request: Request) {
	// Parse the URL to extract query parameters
	const url = new URL(request.url);
	const queryParams = url.searchParams;

	// Extract parameters with defaults
	const username = queryParams.get('username') || 'kiliantyler';
	const branch = queryParams.get('branch') || 'main';
	const gitProvider = queryParams.get('provider') || 'github';
	const repoName = queryParams.get('repo') || 'dotfiles';

	// Determine OS (default to auto-detect from user-agent)
	let os = queryParams.get('os')?.toLowerCase();
	let scriptType: 'powershell' | 'bash';

	// If OS is explicitly provided, use it
	if (os === 'windows') {
		scriptType = 'powershell';
	} else if (os === 'macos' || os === 'linux') {
		scriptType = 'bash';
	} else {
		// Fall back to user-agent detection if OS not specified
		const agent = request.headers.get('user-agent');
		if (agent && agent.toLowerCase().includes('powershell')) {
			scriptType = 'powershell';
			os = 'windows';
		} else {
			scriptType = 'bash';
			os = 'unix'; // Generic term for both macOS and Linux
		}
	}

	// Generate the appropriate script content
	const scriptContent = generateScript(scriptType, {
		username,
		branch,
		provider: gitProvider,
		repoName,
	});

	// Set appropriate Content-Type based on script type
	const contentType = scriptType === 'powershell' ? 'text/plain' : 'text/x-shellscript';
	const ext = scriptType === 'powershell' ? 'ps1' : 'sh';

	// Respond with the dynamically generated script
	return new Response(scriptContent, {
		headers: {
			'Content-Type': contentType,
			'Content-Disposition': `attachment; filename="install.${ext}"`,
		},
	});
}

/**
 * Generates a script based on the provided type and options
 * Uses the appropriate script generator based on the script type
 */
function generateScript(type: ScriptType, options: ScriptOptions): string {
	// Get a properly formatted repository URL for the specified provider
	const repoUrl = getRepositoryUrl(options);

	// Sanitize branch name to prevent security issues
	const sanitizedBranch = sanitizeBranchName(options.branch);

	if (type === 'powershell') {
		return generatePowershellScript(repoUrl, sanitizedBranch);
	} else {
		return generateBashScript(repoUrl, sanitizedBranch);
	}
}

/**
 * Sanitizes a branch name to prevent security issues
 *
 * @param branch The branch name to sanitize
 * @returns A sanitized version of the branch name
 */
function sanitizeBranchName(branch: string): string {
	if (!branch) return 'main'; // Default to main if not specified

	// Remove potentially dangerous characters and limit length
	return branch
		.replace(/[;&|`$<>]/g, '')
		.replace(/\.\.\//g, '') // Prevent directory traversal
		.replace(/\\/g, '')
		.trim()
		.substring(0, 50); // Limit length to prevent issues
}

// Export handleRequest for testing purposes
export { handleRequest };

// Default export for Cloudflare Worker
export default {
	fetch: handleRequest,
};
