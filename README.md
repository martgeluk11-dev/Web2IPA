# Web2IPA

Wrap an HTTPS website in a fullscreen iOS WKWebView app and build an **unsigned** IPA with GitHub Actions.

Site: https://martgeluk11-dev.github.io/Web2IPA/

## One-time backend setup (visitors need no GitHub token)

The static site uses a Cloudflare Worker. The Worker authenticates as a GitHub App, so visitors never see or enter repository credentials.

### 1. GitHub App
Create an app at https://github.com/settings/apps/new:
- Name: Web2IPA Builder
- Homepage: https://martgeluk11-dev.github.io/Web2IPA/
- Disable webhook
- Repository permissions: Actions **Read and write**, Contents **Read-only**, Metadata **Read-only**
- Install it on only `martgeluk11-dev/Web2IPA`

Record its App ID and Installation ID, then generate a private key. Keep the PEM key secret.

### 2. Cloudflare Turnstile
Create a Turnstile widget for hostname `martgeluk11-dev.github.io`. Keep its site key and secret key.

### 3. Cloudflare Worker
Create a Worker named `web2ipa-api`, deploy `worker.js`, then add these secrets in Worker Settings → Variables and Secrets:
- `GITHUB_APP_ID`
- `GITHUB_INSTALLATION_ID`
- `GITHUB_PRIVATE_KEY` (full PEM contents)
- `TURNSTILE_SECRET`

Add this plain-text variable:
- `ALLOWED_ORIGIN` = `https://martgeluk11-dev.github.io`

### 4. Connect the site
In `index.html`, replace:
- `https://web2ipa-api.YOUR-SUBDOMAIN.workers.dev` with your deployed Worker URL
- `TURNSTILE_SITE_KEY` with the Turnstile site key

Commit the change and wait for GitHub Pages to deploy.

## API
- `POST /api/build`: Turnstile verification + GitHub Actions dispatch
- `GET /api/build/:runId`: live run status and steps
- `GET /api/build/:runId/download`: artifact ZIP stream; browser extracts the IPA

## Important
The IPA is unsigned. Normal installation requires signing with a valid Apple signing identity and provisioning profile. This wraps a website in WKWebView; it does not convert it into native Swift code.
