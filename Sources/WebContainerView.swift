import SwiftUI
import WebKit

struct WebContainerView: View {
    @State private var progress: Double = 0
    @State private var isLoading = true
    @State private var hasError = false
    @State private var reloadToken = UUID()

    private var startURL: URL? {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "WEB2IPA_START_URL") as? String,
            let url = URL(string: raw),
            url.scheme == "https",
            url.host != nil
        else { return nil }
        return url
    }

    var body: some View {
        Group {
            if let startURL {
                WebsiteWebView(
                    url: startURL,
                    reloadToken: reloadToken,
                    progress: $progress,
                    isLoading: $isLoading,
                    hasError: $hasError
                )
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    if isLoading {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .tint(.blue)
                            .frame(height: 2)
                            .background(Color.clear)
                    }
                }
                .overlay {
                    if hasError {
                        ContentUnavailableView {
                            Label("Couldn't load this page", systemImage: "wifi.exclamationmark")
                        } description: {
                            Text("Check your internet connection and try again.")
                        } actions: {
                            Button("Try again") {
                                hasError = false
                                reloadToken = UUID()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Website URL missing",
                    systemImage: "link",
                    description: Text("Rebuild this app with a valid HTTPS website URL.")
                )
            }
        }
        .background(Color.white)
    }
}

private struct WebsiteWebView: UIViewRepresentable {
    let url: URL
    let reloadToken: UUID
    @Binding var progress: Double
    @Binding var isLoading: Bool
    @Binding var hasError: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        context.coordinator.observe(webView)
        webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            webView.load(URLRequest(url: url, timeoutInterval: 30))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebsiteWebView
        var lastReloadToken: UUID
        private var observation: NSKeyValueObservation?

        init(parent: WebsiteWebView) {
            self.parent = parent
            self.lastReloadToken = parent.reloadToken
        }

        func observe(_ webView: WKWebView) {
            observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.progress = webView.estimatedProgress
                }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.hasError = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.progress = 1
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.hasError = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.hasError = true
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let target = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            if target.scheme == "https" || target.scheme == "http" {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}
