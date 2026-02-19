## 2025-05-24 - [Secure Configuration Handling]
**Vulnerability:** The configuration UI was unprotected, used plain text fields for secrets, and lacked input validation. It also used `YAML.load_file` which is potentially vulnerable to RCE.
**Learning:** For Rails Engines providing a configuration UI, it's crucial to mask secrets, validate inputs strictly, and ensure the UI is not accidentally exposed at the root route.
**Prevention:** Use `password_field` for secrets, `YAML.safe_load_file` for configuration loading, and move sensitive routes away from the engine root.

## 2025-05-25 - [Insecure Storage of Secrets in Configuration File]
**Vulnerability:** Secrets like `merchant_key` were being written to a plain YAML file (`config/redsys.yml`) in the application directory.
**Learning:** Secrets should never be persisted in plain text files within the application directory. They should be managed via environment variables or encrypted credentials.
**Prevention:** Exclude secrets from YAML serialization and prioritize loading from `ENV` or `Rails.application.credentials`.

## 2025-05-26 - [Insecure Random Order ID Generation]
**Vulnerability:** The gem used Ruby's insecure `rand` method with a small range (5 digits) to generate default order IDs, leading to high collision risk and lack of cryptographic security.
**Learning:** For identifiers in payment systems, cryptographically secure random number generators (like `SecureRandom`) should be used, and the range should be maximized to prevent collisions.
**Prevention:** Use `SecureRandom` instead of `rand` and utilize the full length allowed by the payment gateway (12 digits for Redsys) to ensure uniqueness and security.
