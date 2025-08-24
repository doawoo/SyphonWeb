import MetalKit
import SwiftUI
import WebKit

class WebViewState: ObservableObject {
  @Published var url: URL = URL(string: "https://puppy.surf")!
  @Published var loading: Bool = false
  @Published var texture: MTLTexture?
  @Published var currentUrl: URL?
}

struct WebView: NSViewRepresentable {
  let webView: WKWebView = WKWebView()

  @ObservedObject var state: WebViewState
  @State var currentURL: URL?

  func makeNSView(context: Context) -> WKWebView {
    webView.navigationDelegate = context.coordinator
    webView.load(URLRequest(url: state.url))
    currentURL = state.url
    return webView
  }

  func updateNSView(_ nsView: WKWebView, context: Context) {
    // Only reload if the URL has changed, save the new URL in state
    if state.url.absoluteString != state.currentUrl?.absoluteString {
      nsView.load(URLRequest(url: state.url))
      state.currentUrl = state.url
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebView

    init(_ parent: WebView) {
      self.parent = parent
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      parent.state.loading = true
      NSLog("Loading URL: \(parent.state.url)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      parent.state.loading = false
      NSLog("Done loading URL: \(parent.state.url)")
    }
  }
}
