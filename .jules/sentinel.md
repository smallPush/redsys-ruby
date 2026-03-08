## 2025-05-24 - [Secure Configuration Handling]
**Vulnerability:** The configuration UI was unprotected, used plain text fields for secrets, and lacked input validation. It also used `YAML.load_file` which is potentially vulnerable to RCE.
**Learning:** For Rails Engines providing a configuration UI, it's crucial to mask secrets, validate inputs strictly, and ensure the UI is not accidentally exposed at the root route.
**Prevention:** Use `password_field` for secrets, `YAML.safe_load_file` for configuration loading, and move sensitive routes away from the engine root.

## 2025-05-25 - [Insecure Storage of Secrets in Configuration File]
**Vulnerability:** Secrets like `merchant_key` were being written to a plain YAML file (`config/redsys.yml`) in the application directory.
**Learning:** Secrets should never be persisted in plain text files within the application directory. They should be managed via environment variables or encrypted credentials.
**Prevention:** Exclude secrets from YAML serialization and prioritize loading from `ENV` or `Rails.application.credentials`.

## 2026-02-19 - [Unauthenticated Configuration Endpoint]
**Vulnerability:** The configuration UI in the Rails engine was accessible to unauthenticated users because it inherited directly from ActionController::Base and lacked any authentication filters.
**Learning:** Rails engines must provide a mechanism for host applications to secure engine-provided controllers, typically by making the parent controller configurable and providing authentication hooks.
**Prevention:** Implement a configurable 'parent_controller' and 'before_action' hooks in the engine's base controller to allow integration with the host application's authentication system.

## 2025-05-26 - [Insecure Random Order ID Generation]
**Vulnerability:** The gem used Ruby's insecure `rand` method with a small range (5 digits) to generate default order IDs, leading to high collision risk and lack of cryptographic security.
**Learning:** For identifiers in payment systems, cryptographically secure random number generators (like `SecureRandom`) should be used, and the range should be maximized to prevent collisions.
**Prevention:** Use `SecureRandom` instead of `rand` and utilize the full length allowed by the payment gateway (12 digits for Redsys) to ensure uniqueness and security.

## 2026-02-19 - [Sensitive Data Exposure in View]
**Vulnerability:** Rendering sensitive secrets in the 'value' attribute of a password input field allowed the cleartext secret to be retrieved from the page source.
**Learning:** Even when using `password_field`, Rails may render the `value` attribute if explicitly provided, exposing the secret in the HTML source. Sensitive fields should never have their values pre-filled in the HTML.
**Prevention:** Remove the `value` attribute from sensitive input fields to ensure they remain empty in the rendered HTML, relying on user input for updates.

## 2024-05-24 - Unhandled Exception in Signature Validation
**Vulnerability:** Calling `.empty?` on `nil` parameters within `RedsysRuby::TPV#secure_compare` throws a `NoMethodError`, leading to an unhandled exception. An attacker could potentially cause a Denial-of-Service (DoS) by sending malformed requests with missing signature parameters that evaluate to `nil`.
**Learning:** In Ruby, missing hash keys or intentionally omitted parameters can result in `nil` values being passed to internal methods. Before invoking String methods like `.empty?` or `.bytesize`, input variables must be validated against `nil` (e.g., `return false if a.nil? || b.nil?`).
**Prevention:** Implement explicit `nil` checks early in validation or comparison routines, particularly those processing external input like signatures or payload parameters, to prevent application crashes.

## 2026-02-20 - [Missing Notification URL Support]
**Vulnerability:** The payment integration lacked support for a server-to-server notification URL (Ds_Merchant_MerchantURL), forcing reliance on client-side browser redirects for payment status updates, which can be manipulated or missed.
**Learning:** Payment systems must use asynchronous server-to-server notifications (IPN/Webhooks) to securely confirm transaction status, as client-side redirects are untrustworthy.
**Prevention:** Always provide and configure a secure notification URL that the payment gateway can use to send transaction results directly to the merchant's server.
