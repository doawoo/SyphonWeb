import MetalKit
import SwiftUI
import Syphon
import WebKit

class WebViewState: ObservableObject {
  @Published var url: URL = URL(string: "https://puppy.surf")!
  @Published var loading: Bool = false
  @Published var currentUrl: URL?

  // Metal Related Objects
  var texture: MTLTexture?
  var frameServer: SyphonMetalServer?
  var commandQueue: MTLCommandQueue?
  var layer: CAMetalLayer?
  var graphicsContext: CGContext?
  var region: MTLRegion?

  @MainActor
  func initMetal(width: CGFloat, height: CGFloat, scaleFactor: CGFloat) {
    commandQueue = server.device.makeCommandQueue()
    layer = CAMetalLayer()
    layer?.device = server.device
    layer?.pixelFormat = .rgba8Unorm
    layer?.maximumDrawableCount = 2
    layer?.drawableSize = CGSize(width: width, height: height)

    let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .rgba8Unorm,
      width: Int(width * scaleFactor),
      height: Int(height * scaleFactor),
      mipmapped: false
    )
    textureDescriptor.usage.insert(MTLTextureUsage.shaderRead)
    textureDescriptor.usage.insert(MTLTextureUsage.shaderWrite)

    texture = server.device.makeTexture(descriptor: textureDescriptor)
    graphicsContext = CGContext(
      data: nil,
      width: texture!.width,
      height: texture!.height,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!

    region = MTLRegionMake2D(0, 0, texture!.width, texture!.height)
  }
}

struct WebView: NSViewRepresentable {
  let webView: WKWebView = WKWebView()

  @ObservedObject var state: WebViewState

  func makeNSView(context: Context) -> WKWebView {
    webView.navigationDelegate = context.coordinator
    webView.load(URLRequest(url: state.url))

    Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
      Task { @MainActor in
        captureFrame()
      }
    }

    return webView
  }

  func printTimeElapsedWhenRunningCode(title: String, operation: () -> Void) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s.")
  }

  func captureFrame() {
    if state.texture != nil && state.graphicsContext != nil && !state.loading {
      let commandBuffer: (any MTLCommandBuffer)? = state.commandQueue?.makeCommandBuffer()

      webView.getFrame(
        context: state.graphicsContext!, texture: state.texture!, region: state.region!)
      state.frameServer?.publishFrameTexture(
        state.texture!, on: commandBuffer!,
        imageRegion: NSRect(x: 0, y: 0, width: state.texture!.width, height: state.texture!.height),
        flipped: false)
      commandBuffer?.commit()
    }
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
