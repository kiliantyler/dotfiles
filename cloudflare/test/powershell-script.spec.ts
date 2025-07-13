import { describe, expect, it } from 'vitest';
import { performRequest } from './helpers';

describe('PowerShell Script Generation', () => {
	it('responds with PowerShell script when os=windows param is present', async () => {
		const response = await performRequest({ os: 'windows' });
		const responseText = await response.text();

		// Check content type and disposition
		expect(response.headers.get('Content-Type')).toBe('text/plain');
		expect(response.headers.get('Content-Disposition')).toBe('attachment; filename="install.ps1"');

		// Check script content for key elements
		expect(responseText).toContain('#Requires -Version 7.3');
		expect(responseText).toContain('https://github.com/kiliantyler/dotfiles.git');
		expect(responseText).toContain('--branch main');
	});

	it('detects PowerShell from user agent and returns PS1 script', async () => {
		const response = await performRequest(
			{}, // No parameters
			{ 'User-Agent': 'Mozilla/5.0 Windows PowerShell/5.1' }
		);

		// Should detect PowerShell from UA and return PS1
		expect(response.headers.get('Content-Type')).toBe('text/plain');
		expect(response.headers.get('Content-Disposition')).toBe('attachment; filename="install.ps1"');
	});

	it('includes custom parameters in PowerShell script', async () => {
		const response = await performRequest({
			os: 'windows',
			username: 'winuser',
			provider: 'bitbucket',
			branch: 'testing',
			repo: 'win-config',
		});

		const responseText = await response.text();

		expect(responseText).toContain('https://bitbucket.org/winuser/win-config.git');
		expect(responseText).toContain('--branch testing');
	});

	it('overwrites user agent detection with explicit os parameter', async () => {
		// Windows UA but with explicit macos parameter
		const response = await performRequest({ os: 'macos' }, { 'User-Agent': 'Windows PowerShell/7.0' });

		// Should ignore Windows UA and return bash script due to explicit os=macos
		expect(response.headers.get('Content-Type')).toBe('text/x-shellscript');
		expect(response.headers.get('Content-Disposition')).toBe('attachment; filename="install.sh"');
	});
});
