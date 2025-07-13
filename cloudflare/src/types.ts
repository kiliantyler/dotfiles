/**
 * Types and interfaces for the script generator
 */

/**
 * Configuration options for script generation
 */
export interface ScriptOptions {
	username: string;
	provider: string;
	branch: string;
	repoName: string;
}

/**
 * Script type enumeration
 */
export type ScriptType = 'powershell' | 'bash';

/**
 * Get a properly formatted repository URL based on the provider
 * @param options Script options containing provider, username, and repo name
 * @returns A properly formatted Git URL
 */
export function getRepositoryUrl(options: ScriptOptions): string {
	const { provider, username, repoName } = options;

	// Sanitize inputs to prevent script injection and other security issues
	const sanitizedProvider = sanitizeInput(provider);
	const sanitizedUsername = sanitizeInput(username);
	const sanitizedRepoName = sanitizeInput(repoName);

	// Format URLs for common Git providers
	switch (sanitizedProvider.toLowerCase()) {
		case 'github':
			return `https://github.com/${sanitizedUsername}/${sanitizedRepoName}.git`;
		case 'gitlab':
			return `https://gitlab.com/${sanitizedUsername}/${sanitizedRepoName}.git`;
		case 'bitbucket':
			return `https://bitbucket.org/${sanitizedUsername}/${sanitizedRepoName}.git`;
		default:
			// For custom or unknown providers, use a generic format
			// This assumes the provider is a domain name (e.g., "gitlab.example.com")
			// Sanitize as a hostname - remove any protocol/path separators
			const sanitizedDomain = sanitizedProvider.replace(/[\/\\<>:"'|?*]/g, '');
			return `https://${sanitizedDomain}/${sanitizedUsername}/${sanitizedRepoName}.git`;
	}
}

/**
 * Sanitizes a string input to prevent injection attacks
 *
 * @param input The string to sanitize
 * @returns A sanitized version of the input
 */
function sanitizeInput(input: string): string {
	if (!input) return '';

	// Remove script tags, potential command injections and other dangerous characters
	return input
		.replace(/<\/?script[^>]*>/gi, '')
		.replace(/[;&|`$]/g, '')
		.replace(/rm -rf/gi, 'removed')
		.trim();
}
