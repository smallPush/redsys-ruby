# Project Overview
RedsysRuby is a Ruby gem providing integration for making payments with Redsys using the HMAC-SHA256 signature algorithm. It includes a Rails Engine that supplies a configuration interface, payment helpers, and premium success/failure pages for Ruby on Rails applications.

# Tech Stack
* Ruby (>= 3.2.0)
* Ruby on Rails (Railties, ActiveModel ~> 7.0)
* RSpec (Testing framework)
* OpenSSL (HMAC-SHA256 and 3DES cryptography)

# Project Architecture
The project is structured as a Ruby Gem containing a Rails Engine, following the standard Rails MVC (Model-View-Controller) architectural pattern:
* `app/`: Contains the Rails engine components (controllers, helpers, models, and views) for the payment UI and configuration interface.
* `lib/`: Houses the core gem logic, including the Redsys HMAC-SHA256 signature implementation (`lib/redsys-ruby/tpv.rb`) and the Rails engine initialization (`lib/redsys-ruby/engine.rb`).
* `spec/`: Component-specific RSpec tests mirroring the internal library and app structure to maintain modularity.

# Coding Standards
* **Typing Strictness**: Utilize `# frozen_string_literal: true` at the top of all Ruby files. Code changes should be focused and under 50 lines.
* **Naming Conventions**: Follow standard Ruby conventions (PascalCase for classes/modules, snake_case for methods and variables). Keys in Ruby hashes should be normalized to strings using `transform_keys(&:to_s)` within methods to ensure consistent internal access.
* **Error Handling**: Avoid inline `rescue` (catches `StandardError` broadly); prefer structured `begin...rescue` blocks. Explicitly check for `nil` inputs before invoking string or array methods to prevent `NoMethodError`.
* **Calculations**: Always use `BigDecimal` (via `to_d`) and require `bigdecimal/util` for currency and financial calculations to avoid floating-point precision errors associated with `Float`.

# Critical AI Rules
1. **Secure Configuration**: Secrets (like `merchant_key`) must be managed via environment variables (e.g., `REDSYS_MERCHANT_KEY`) or Rails encrypted credentials and completely excluded from plain-text configuration files.
2. **Security Documentation**: Security-related learnings and vulnerability details must be documented in `.jules/sentinel.md` using the exact format: `## Date - [Title] \n **Vulnerability:** ... \n **Learning:** ... \n **Prevention:** ...`.
3. **No NPM/Yarn**: For JavaScript dependency management, only `pnpm` is permitted; `npm` and `yarn` must be strictly avoided.
4. **Testing Isolation**: When testing components that rely on `Rails` methods (like `Rails.root` or `Rails.env`) in isolation, safely stub `Rails` to avoid uninitialized constant errors without permanently polluting the global namespace.
5. **PR Naming**: PR titles must strictly follow formats based on the type of change (e.g., `🛡️ Sentinel: [CRITICAL/HIGH] Fix [vulnerability]`, `🧹 [code health improvement]`, `🧪 [testing improvement]`, `⚡ [performance improvement]`, `🎨 Palette: [UX improvement]`).