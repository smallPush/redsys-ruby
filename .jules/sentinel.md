## 2025-05-24 - [Secure Configuration Handling]
**Vulnerability:** The configuration UI was unprotected, used plain text fields for secrets, and lacked input validation. It also used `YAML.load_file` which is potentially vulnerable to RCE.
**Learning:** For Rails Engines providing a configuration UI, it's crucial to mask secrets, validate inputs strictly, and ensure the UI is not accidentally exposed at the root route.
**Prevention:** Use `password_field` for secrets, `YAML.safe_load_file` for configuration loading, and move sensitive routes away from the engine root.
