/**
 * Main test file that imports all test modules
 * This allows running all tests with a single command
 */

// Import all test modules
import './bash-script.spec';
import './error-handling.spec';
import './powershell-script.spec';
import './url-generation.spec';

/**
 * Note: When adding new test files, make sure to import them here
 * to include them in the test suite.
 *
 * Each test file should focus on a specific area of functionality:
 * - bash-script.spec.ts - Tests for Bash script generation for Linux/macOS
 * - powershell-script.spec.ts - Tests for PowerShell script generation for Windows
 * - url-generation.spec.ts - Tests for Git provider URL generation
 * - error-handling.spec.ts - Tests for input validation and error handling
 */
