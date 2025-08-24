import MetalKit
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
  var texture: MTLTexture?
  let webView: WKWebView = WKWebView()
  let url: URL

  func makeNSView(context: Context) -> WKWebView {

    webView.load(URLRequest(url: url))
    return webView
  }

  func updateNSView(_ nsView: WKWebView, context: Context) {}
}
