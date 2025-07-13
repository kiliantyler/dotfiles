import { describe, expect, it } from 'vitest';
import { performRequest } from './helpers';

describe('Repository URL Generation', () => {
	it('handles GitHub URLs correctly', async () => {
		const response = await performRequest({
			provider: 'github',
			username: 'testuser',
			repo: 'test-repo',
		});
		const responseText = await response.text();

		expect(responseText).toContain('https://github.com/testuser/test-repo.git');
	});

	it('handles GitLab URLs correctly', async () => {
		const response = await performRequest({
			provider: 'gitlab',
			username: 'testuser',
			repo: 'test-repo',
		});
		const responseText = await response.text();

		expect(responseText).toContain('https://gitlab.com/testuser/test-repo.git');
	});

	it('handles Bitbucket URLs correctly', async () => {
		const response = await performRequest({
			provider: 'bitbucket',
			username: 'testuser',
			repo: 'test-repo',
		});
		const responseText = await response.text();

		expect(responseText).toContain('https://bitbucket.org/testuser/test-repo.git');
	});

	it('handles custom domain providers correctly', async () => {
		const response = await performRequest({
			provider: 'git.example.com',
			username: 'testuser',
			repo: 'test-repo',
		});
		const responseText = await response.text();

		expect(responseText).toContain('https://git.example.com/testuser/test-repo.git');
	});

	it('handles case-insensitive provider names', async () => {
		const response = await performRequest({
			provider: 'GitHuB', // Mixed case
			username: 'testuser',
			repo: 'test-repo',
		});
		const responseText = await response.text();

		// Should normalize to lowercase for the switch statement
		expect(responseText).toContain('https://github.com/testuser/test-repo.git');
	});

	it('defaults to "dotfiles" repo name when not specified', async () => {
		const response = await performRequest({
			provider: 'github',
			username: 'testuser',
			// repo not specified
		});
		const responseText = await response.text();

		expect(responseText).toContain('https://github.com/testuser/dotfiles.git');
	});
});
