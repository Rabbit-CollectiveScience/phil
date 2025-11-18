# L3 Infrastructure Layer Tests

Unit tests for the infrastructure layer components.

## Test Files

- `config/` - Configuration loading and validation tests
- `db/` - Database repositories and MongoDB client tests  
- `storage/` - File storage (GCS, Local) tests
- `image-manager/` - Image processing and management tests

## Mocking Strategy

These tests mock external dependencies:
- MongoDB client and collections
- Google Cloud Storage SDK
- File system operations
- Sharp image processing library