# PingOne OpenAPI Specifications

This repository contains the official OpenAPI specifications for the PingOne Platform. These specifications are automatically generated from our platform's source code to ensure they remain current. You can use them to build integrations, generate client SDKs, and explore PingOne API capabilities.

> [!IMPORTANT]  
> This is a project in active development, and the specifications are built out incrementally. If there is an endpoint that you need, please see the [Feedback and Issues](#feedback-and-issues) section.

## Possible Uses

You can use these specifications to:

  * **Generate Client SDKs:** Use open source tools like [OpenAPI Generator](https://openapi-generator.tech/) to create typed client libraries for your application's programming language where we don't provide an existing SDK.
    * Available SDKs that have been built from this specification can be found at [Configuration and User Management SDKs](https://developer.pingidentity.com/config-user-management-sdks.html) and on [Ping Identity's GitHub](https://github.com/search?q=topic%3Asdk+topic%3Amanagement-api+topic%3Apingone+org%3Apingidentity+fork%3Atrue&type=repositories)
  * **Configure API Tools:** Import the specs into tools like Postman or Insomnia to create ready-to-use collections for exploring and testing the APIs.
    * Ping Identity provide comprehensive Postman collections, see the [PingOne API Reference](https://apidocs.pingidentity.com/pingone/platform/v1/api/#the-pingone-postman-collections) for more information.
  * **Create Mock Servers:** Generate a mock API server for local development and testing, allowing you to build against the PingOne API without a live connection.
  * **Automate Testing:** Use the specifications as a contract to drive automated API and integration tests.

Have you built something interesting with these specs? We'd love to hear about it. **[Share your project on the PingOne Community pages\!](https://support.pingidentity.com/s/topic/0TO1W000000ddO4WAI/pingone)**

## Resources

  * **[Full API Documentation](https://apidocs.pingidentity.com/pingone/platform/v1/api/)**: The complete, published API reference.
  * **[Developer Community](https://support.pingidentity.com/s/topic/0TO1W000000ddO4WAI/pingone)**: Join discussions and ask questions.
  * **[Ping Identity Support](https://support.pingidentity.com/)**: Open a support case for technical assistance.

## Directory Structure

Specifications are organized by OpenAPI version and the corresponding PingOne API subdomain.  There are multiple variants of the same specification depending on the use case.

The structure is: `./specifications/[OpenAPI Version]/[Subdomain]/[variant]/openapi.yaml`

For example, the combined (full) OpenAPI `3.1` specification for the management APIs (`api.pingone.com`) is located at:

```bash
.specifications/3.1/api/combined/openapi.yaml
```

## Contributing

### Feedback and Issues

Please use this repository's issue tracker to submit feedback, bug reports, or enhancement requests. For existing issues, you can add a 👍 reaction to help our team gauge priority.

### Pull Request Guidelines

Due to our automated generation process, **we cannot merge pull requests that modify the YAML or JSON specification files.** Any manual changes would be overwritten by our pipeline.

We welcome pull requests for:

  * Repository management (e.g., scripts, GitHub Actions)
  * Documentation updates
  * Other non-specification content

**Note:** While we cannot merge pull requests that modify specifications, they can be a valuable way to illustrate a proposed change when you submit an issue. We will use the illustated changes in triage to port into the internal pipeline, however we will close the pull request without merging to the main branch.