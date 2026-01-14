---
name: sdk-builder
description: Guided workflow for generating SDKs from OpenAPI specifications. Use when users request SDK generation, build, or creation for specific products (pingone, identitycloud, etc.) and languages (go, python, etc.). Triggers on requests like "build the X SDK", "generate Y client library", "create Z API SDK", or any request to produce SDK code from OpenAPI specs.
---

# SDK Builder

Generates SDKs from OpenAPI specifications using a multi-step guided workflow.

## Workflow

### Step 1: Determine OAS Source

Ask the user for the OpenAPI specification source. If not provided, use default for `pingone`:
```
specification/3.1/api/sdk-generation/openapi.yaml
```

If not `pingone`, as the user to clarify the source.

OAS source can be:
- File path (local file)
- HTTP/HTTPS URL (remote file)
- FTP URL (remote file)
- Content in the request itself

### Step 2: Clarify Output Location

Ask where to place the generated SDK:

**Option A: Directory output (default)**
- Use the Makefile's default pattern: `dist/{language}/{product}/{version}`
- Allow custom directory override via TARGET_DIR

**Option B: Raise PR against remote project**
- Defer to a future "pr-raiser" skill (not yet implemented)
- For now, generate to default staging area: `dist/{language}/{product}/{version}`

### Step 3: Gather Required Parameters

Collect from user (all required):
- `LANGUAGE` - SDK language (e.g., go, python)
- `PRODUCT` - Product code (e.g., pingone, identitycloud)
- `VERSION` - SDK version - **MUST** be explicitly provided, never use a default
  - Expected format: Semver v2 with `v` prefix (e.g., v0.7.0, v1.2.3)
  - If version matches expected format, continue without interruption
  - If version does NOT match expected format, prompt user to clarify the intended version format

Optional:
- `TARGET_DIR` - Custom output directory

**Important**: The VERSION parameter must always be explicitly specified by the user or agent. Never assume or default a version number.

### Step 4: Retrieve Remote OAS (if needed)

If OAS source is remote (HTTP, HTTPS, FTP):
1. Use `run_in_terminal` with `curl` to download to temporary location
2. Store downloaded file path for use in next step

Example:
```bash
curl -L -o /tmp/openapi-spec.yaml "https://pingidentity.com/openapi.yaml"
```

### Step 5: Execute SDK Generation

Run Makefile `run` target with parameters:

```bash
make run \
  INPUT_OAS="/path/to/spec.yaml" \
  LANGUAGE=go \
  PRODUCT=pingone \
  VERSION=v0.0.1 \
  [TARGET_DIR=/custom/path]
```

The Makefile will:
1. Build the Docker image
2. Generate SDK to the target directory
3. Apply language-specific post-processing

### Step 6: Confirm Completion

Report to user:
- Location of generated SDK
- Next steps (if PR workflow was requested but deferred)

## Notes

- Always verify required parameters before running generation
- For remote OAS files, validate download succeeded before proceeding
- Default output follows pattern: `dist/{language}/{product}/{version}`
- PR workflow requires future "pr-raiser" skill integration
