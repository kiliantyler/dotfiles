# Testing the Dotfiles Installation Worker

This document explains the testing approach for the Cloudflare Worker.

## Test Structure

Tests are organized into modular files, each focusing on a specific area of functionality:

1. **bash-script.spec.ts**: Tests Bash script generation for Linux/macOS
2. **powershell-script.spec.ts**: Tests PowerShell script generation for Windows
3. **url-generation.spec.ts**: Tests Git provider URL formation and handling
4. **error-handling.spec.ts**: Tests input validation and error handling

The tests are coordinated through a main index.ts file that imports all test modules.

## Running Tests

To run all tests:

```bash
cd cloudflare
npm test
```

To run a specific test file:

```bash
cd cloudflare
npm test -- bash-script.spec.ts
```

## Test Implementation Details

The tests use a direct approach by importing and calling the `handleRequest` function exported from the main worker file. Each test follows this pattern:

1. Create a mock request with specific query parameters and/or headers
2. Call the `handleRequest` function with this request
3. Examine the response headers and body to verify correct behavior

### Testing OS Detection

The tests verify that:

- The `os` query parameter explicitly overrides user-agent detection
- PowerShell is properly detected from the user-agent string
- Content types and filenames are set correctly for each OS

### Testing Query Parameters

Tests verify that all supported query parameters work correctly:

- `username`: Controls the Git username in the repository URL
- `provider`: Sets the Git provider (github, gitlab, bitbucket, or custom)
- `branch`: Specifies which branch to clone
- `repo`: Sets the repository name

### Testing Input Validation

The error handling tests verify that the worker handles unusual inputs gracefully, including:

- Special characters in usernames
- Potentially malicious inputs
- Path traversal attempts

## Adding New Tests

To add new tests:

1. Identify which test file is most appropriate for your test, or create a new one for a distinct area
2. Add test cases following the existing patterns using the helpers
3. Import your new test file in `test/index.ts` if you created a new file
4. Run the tests to ensure everything passes

### Test Helpers

Common testing utilities are available in `test/helpers.ts`:

- `createRequest()`: Creates a request with specified query parameters and headers
- `performRequest()`: Creates a request and calls handleRequest() in one step

## Test Coverage

The current tests cover:

- Default parameter handling
- All supported query parameters
- OS detection logic
- Content type and disposition headers
- Script content validation
- Git URL generation for different providers
- Error handling and input validation
