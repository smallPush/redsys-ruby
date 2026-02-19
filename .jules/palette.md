## 2025-05-15 - Redsys Payment Trust Markers
**Learning:** Adding trust markers like "Secure Payment" notices and lock icons is crucial for UX in financial transactions, even in demo or redirect pages. It reduces user anxiety before being redirected to an external gateway.
**Action:** Always include trust signals (lock icons, security text) near payment-related CTA buttons.

## 2025-05-15 - Immediate Feedback on Redirect
**Learning:** For forms that redirect to an external site (like Redsys), providing immediate feedback (disabling button, changing text to "Processing...") is essential to prevent multiple clicks and reassure the user that the redirection is in progress.
**Action:** Use `data-disable-with` or a simple `onsubmit` handler for all redirect-heavy forms.
