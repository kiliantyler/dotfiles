import { describe, expect, it } from 'vitest';
import { handleRequest } from '../src/index';
import { performRequest } from './helpers';

describe('Error Handling', () => {
	it('returns a valid script even with unusual username characters', async () => {
		const response = await performRequest({
			username: '@#$weird-user!',
		});

		// Should still return a successful response
		expect(response.status).toBe(200);

		// Verify the response is a valid script
		const responseText = await response.text();
		expect(responseText).toContain('#!/usr/bin/env bash');
		expect(responseText).toContain('init --apply');
	});

	it('sanitizes potential malicious inputs', async () => {
		const response = await performRequest({
			provider: '<script>alert("xss")</script>',
			username: '"; rm -rf /; echo "',
			branch: '../../../etc/passwd',
			repo: ' spaces in name ',
		});

		// Should still return a valid response
		expect(response.status).toBe(200);

		const responseText = await response.text();
		// Script should be generated but should sanitize inputs appropriately
		expect(responseText).not.toContain('<script>');
		expect(responseText).not.toMatch(/rm -rf/);
	});

	it('handles empty parameters gracefully', async () => {
		const response = await performRequest({
			username: '',
			provider: '',
			branch: '',
			repo: '',
		});

		// Should use defaults for empty parameters
		expect(response.status).toBe(200);

		const responseText = await response.text();
		// Just check that we get a valid script with defaults
		expect(responseText).toContain('#!/usr/bin/env bash');
		expect(responseText).toContain('init --apply');
		expect(responseText).toContain('kiliantyler');
		expect(responseText).toContain('main');
	});

	it('handles reasonably long parameter values', async () => {
		// Use a more reasonable length that won't exceed URL limits or command line limits
		const longString = 'a'.repeat(20);
		const response = await performRequest({
			username: longString,
			provider: 'github',
			branch: longString,
			repo: longString,
		});

		// Should handle long input gracefully
		expect(response.status).toBe(200);

		const responseText = await response.text();
		// Just verify the script generated successfully and has the key parts
		expect(responseText).toContain('#!/usr/bin/env bash');
		expect(responseText).toContain('init --apply');
		expect(responseText).toContain('a'.repeat(10)); // At least part of our string should be there
	});

	it('gracefully handles unknown query parameters', async () => {
		// Create request with custom URL to add unknown parameters
		const url = new URL('https://install.dotfiles.wiki/');
		url.searchParams.append('username', 'testuser');
		url.searchParams.append('nonexistent', 'parameter');
		url.searchParams.append('another', 'unknown');

		const request = new Request(url.toString());
		const response = await handleRequest(request);

		// Should ignore unknown parameters and work normally
		expect(response.status).toBe(200);

		const responseText = await response.text();
		expect(responseText).toContain('https://github.com/testuser/dotfiles.git');
	});
});
