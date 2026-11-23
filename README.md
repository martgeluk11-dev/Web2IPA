# Web2IPA

Turn a website into a simple fullscreen iOS app wrapper and build an **unsigned IPA** with GitHub Actions.

## Use the Web2IPA website

Open **https://martgeluk11-dev.github.io/Web2IPA/** after the Pages deployment completes.

1. Enter the full HTTPS website URL.
2. Enter the app name (up to 30 characters).
3. Enter a unique Bundle ID, such as `com.yourname.mywebsite`.
4. Create a fine-grained GitHub token for **only this repository** with **Actions: Read and write** permission.
5. Paste the token into the website and press **Build my IPA**.
6. Follow the GitHub Actions run link. When it succeeds, download the `Web2IPA-unsigned-IPA` artifact.

The website sends the token directly from your browser to GitHub's API. It does not save the token in local storage or send it to a Web2IPA backend. The page clears the token field after the request. Never share your token or paste it into any other website.

## First-time setup

The `Deploy Web2IPA website` workflow deploys the static website to GitHub Pages. It runs automatically when `index.html` or the deploy workflow changes. If Pages has not been enabled for the repository, the workflow attempts to enable it.

## Important: unsigned means not ready to install

This project deliberately builds without an Apple signing identity. The IPA is a build artifact, not an install-ready app. To install it on a real iPhone or iPad, it must be signed with an appropriate Apple provisioning profile/certificate. A SHA-256 checksum can verify that a downloaded file has not changed; it does not sign the app or prove that the app is safe.

## What the app does

- Opens the chosen HTTPS website in a fullscreen WKWebView.
- Supports normal web navigation and swipe-back/forward gestures.
- Shows a small loading indicator and a retry screen if loading fails.
- Uses the app name and bundle identifier supplied to the workflow.

## Limitations

- This is a website wrapper, not a native conversion of the website.
- Website features that require unsupported browser APIs, special permissions, or external browser flows may not work exactly like Safari.
- The workflow currently uses a standard app icon; custom icon upload is not included yet.
- The workflow artifact is retained for 7 days.

## Privacy

Only submit a website URL you are comfortable sending to GitHub Actions. Do not put passwords, access tokens, private links, or confidential information into workflow inputs. The wrapper loads the website directly on the device; it does not upload the site's contents to this repository.

## Development

The app uses SwiftUI and WKWebView. The Xcode project is generated from `project.yml` using XcodeGen on a GitHub-hosted macOS runner.
