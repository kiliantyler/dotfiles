// Common helper functions for tests

import { handleRequest } from '../src/index';

/**
 * Helper function to create a request with specified query parameters and headers
 */
export function createRequest(queryParams = {}, headers = {}) {
	// Build URL with query parameters
	const url = new URL('https://install.dotfiles.wiki/');
	Object.entries(queryParams).forEach(([key, value]) => {
		url.searchParams.append(key, String(value));
	});

	// Create request with headers
	return new Request(url.toString(), {
		headers: new Headers(headers),
	});
}

/**
 * Helper function to perform a request and get the response
 */
export async function performRequest(queryParams = {}, headers = {}) {
	const request = createRequest(queryParams, headers);
	return await handleRequest(request);
}
