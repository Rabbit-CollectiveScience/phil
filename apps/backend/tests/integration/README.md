# Integration Tests Setup

This document explains how to set up and run integration tests for MongoDB and Google Cloud Storage.

## Prerequisites

### MongoDB Integration Tests

1. **MongoDB Instance**: You need a running MongoDB instance for testing
   - Local MongoDB: Install and run MongoDB locally
   - MongoDB Atlas: Create a free cluster
   - Docker: `docker run --name saikum-test-mongo -p 27017:27017 -d mongo:latest`

2. **Environment Variables**: Set the following environment variable:
   ```bash
   export MONGO_DB_CONNECTION_STRING_INTEGRATION="mongodb://localhost:27017/saikum_integration_test"
   # Or for MongoDB Atlas:
   # export MONGO_DB_CONNECTION_STRING_INTEGRATION="mongodb+srv://user:pass@cluster.mongodb.net/saikum_integration_test"
   ```

### Google Cloud Storage Integration Tests

1. **GCS Project and Bucket**: 
   - Create a Google Cloud Project
   - Enable Cloud Storage API
   - Create a test bucket (use a unique name)

2. **Authentication**: Choose one of these options:

   **Option A: Service Account Key File** (for local testing)
   ```bash
   # Create service account in Google Cloud Console
   # Download JSON key file
   export GCS_BUCKET_NAME_INTEGRATION="your-test-bucket-name"
   export GCS_PROJECT_ID_INTEGRATION="your-gcp-project-id"
   export GCS_KEY_FILENAME_INTEGRATION="/path/to/service-account-key.json"
   ```

   **Option B: Application Default Credentials** (for Cloud environments)
   ```bash
   # If running on Google Cloud (Cloud Run, Compute Engine, etc.)
   export GCS_BUCKET_NAME_INTEGRATION="your-test-bucket-name"
   export GCS_PROJECT_ID_INTEGRATION="your-gcp-project-id"
   # GCS_KEY_FILENAME_INTEGRATION not needed - uses default service account
   ```

   **Option C: gcloud CLI** (for local development)
   ```bash
   # Authenticate with gcloud CLI
   gcloud auth application-default login
   export GCS_BUCKET_NAME_INTEGRATION="your-test-bucket-name"
   export GCS_PROJECT_ID_INTEGRATION="your-gcp-project-id"
   ```

### Google Cloud Vision API Integration Tests

1. **Vision API Setup**:
   - Use the same Google Cloud Project as GCS
   - Enable Vision API in Google Cloud Console
   - Ensure your service account has "Cloud Vision API User" role

2. **Environment Variables** (same as GCS):
   ```bash
   export GCS_PROJECT_ID_INTEGRATION="your-gcp-project-id"
   export GCS_KEY_FILENAME_INTEGRATION="/path/to/service-account-key.json"
   export GCS_BUCKET_NAME_INTEGRATION="your-test-bucket-name" # Optional, for GCS URI tests
   ```

3. **API Quotas**: 
   - Vision API has free tier limits (1000 requests/month)
   - Consider using a separate test project to avoid hitting production quotas
   - Monitor usage in Google Cloud Console

## Running Tests

### Run All Integration Tests
```bash
npm run test:integration
```

### Run Specific Integration Tests
```bash
# MongoDB only
npm test -- tests/integration/db/mongodb.integration.test.ts

# GCS only  
npm test -- tests/integration/storage/gcs.integration.test.ts
```

### Run Both Unit and Integration Tests
```bash
npm run test:all
```

## Test Behavior

- **Skipping**: Tests automatically skip if required environment variables are not set
- **Cleanup**: Tests clean up after themselves (delete test files, collections)
- **Isolation**: Each test is isolated and doesn't affect others
- **Performance**: Tests include performance measurements and assertions

## Environment Variables Summary

| Variable | Purpose | Required |
|----------|---------|----------|
| `MONGO_DB_CONNECTION_STRING_INTEGRATION` | MongoDB connection for integration tests | For MongoDB tests |
| `GCS_BUCKET_NAME_INTEGRATION` | GCS bucket name for testing | For GCS tests |
| `GCS_PROJECT_ID_INTEGRATION` | Google Cloud Project ID | For GCS and Vision API tests |
| `GCS_KEY_FILENAME_INTEGRATION` | Path to service account key | Optional (for local dev) |

## Troubleshooting

### MongoDB Issues
- **Connection refused**: Ensure MongoDB is running on the specified port
- **Authentication failed**: Check username/password in connection string
- **Database access**: Ensure user has read/write permissions

### GCS Issues  
- **403 Forbidden**: Check service account permissions (Storage Admin role)
- **404 Not Found**: Verify bucket name and existence
- **Authentication**: Ensure credentials are properly configured
- **Network**: Check firewall/proxy settings for Google APIs access

### Vision API Issues
- **403 Forbidden**: Check Vision API is enabled and service account has "Cloud Vision API User" role
- **Quota Exceeded**: Monitor API usage in Google Cloud Console (1000 free requests/month)
- **Invalid Image**: Ensure test images are valid formats (JPEG, PNG, GIF, BMP, WebP, RAW, ICO, PDF, TIFF)
- **Authentication**: Same credentials as GCS - ensure service account key is valid

## Test Data

Integration tests create temporary data with prefixes:
- MongoDB: Collections named `integration_test_collection`
- GCS: Files prefixed with `integration-test-`
- Vision API: Uses test images generated programmatically (no external resources created)

All test data is automatically cleaned up after test completion.