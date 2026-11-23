# Web2IPA

Turn a website into a simple fullscreen iOS app wrapper and build an **unsigned IPA** with GitHub Actions.

## Build your IPA

1. Open the **Actions** tab in this repository.
2. Select **Build Web2IPA**.
3. Press **Run workflow**.
4. Enter:
   - **Website URL:** the full HTTPS address, such as `https://example.com`
   - **App name:** the name shown below the icon (up to 30 characters)
   - **Bundle ID:** a unique identifier, such as `com.yourname.mywebsite`
5. Start the workflow and wait for it to finish.
6. Open the completed workflow run, scroll to **Artifacts**, and download **Web2IPA-unsigned-IPA**.

The artifact contains `Web2IPA-unsigned.ipa` and its SHA-256 checksum file.

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
