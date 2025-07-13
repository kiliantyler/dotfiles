import { describe, expect, it } from 'vitest';
import { performRequest } from './helpers';

describe('Bash Script Generation', () => {
	it('responds with bash script for default parameters', async () => {
		const response = await performRequest();
		const responseText = await response.text();

		// Check content type and disposition
		expect(response.headers.get('Content-Type')).toBe('text/x-shellscript');
		expect(response.headers.get('Content-Disposition')).toBe('attachment; filename="install.sh"');

		// Check script content for key elements
		expect(responseText).toContain('#!/usr/bin/env bash');
		expect(responseText).toContain('kiliantyler');
		expect(responseText).toContain('dotfiles');
		expect(responseText).toContain('init --apply');
		expect(responseText).toContain('main');
	});

	it('includes custom username, provider and branch in bash script', async () => {
		const response = await performRequest({
			username: 'testuser',
			provider: 'gitlab',
			branch: 'develop',
		});

		const responseText = await response.text();

		// Check that our custom parameters are included
		expect(responseText).toContain('gitlab.com');
		expect(responseText).toContain('testuser');
		expect(responseText).toContain('develop');
	});

	it('handles custom repo name in bash script', async () => {
		const response = await performRequest({
			username: 'testuser',
			repo: 'custom-dotfiles',
		});

		const responseText = await response.text();

		expect(responseText).toContain('https://github.com/testuser/custom-dotfiles.git');
	});

	it('forces bash script when os=linux param is present', async () => {
		// PowerShell UA would normally trigger PS1
		const response = await performRequest({ os: 'linux' }, { 'User-Agent': 'PowerShell/7.0' });

		// Even with PowerShell UA, should still return bash script
		expect(response.headers.get('Content-Type')).toBe('text/x-shellscript');
		expect(response.headers.get('Content-Disposition')).toBe('attachment; filename="install.sh"');
	});

	it('forces bash script when os=macos param is present', async () => {
		const response = await performRequest({ os: 'macos' });

		expect(response.headers.get('Content-Type')).toBe('text/x-shellscript');
		expect(response.headers.get('Content-Disposition')).toBe('attachment; filename="install.sh"');
	});
});
