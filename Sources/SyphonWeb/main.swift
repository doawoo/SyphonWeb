import AppKit
import MetalKit
import SwiftUI
import Syphon

var activity: NSObjectProtocol?
activity = ProcessInfo().beginActivity(options: ProcessInfo.ActivityOptions.userInitiated, reason: "No Napping!")

let viewWidth = 1280.0
let viewHeight = 720.0
let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice()!
let server: SyphonMetalServer = SyphonMetalServer.init(name: "SyphonWeb", device: metalDevice)

// AppKit Stuff
class WindowDelegate: NSObject, NSWindowDelegate {

  func windowWillClose(_ notification: Notification) {
    NSApplication.shared.terminate(0)
  }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  let mainWindow: NSWindow = NSWindow()
  let utilityWindow: NSWindow = NSWindow()

  let mainWindowDelegate: WindowDelegate = WindowDelegate()
  let utilityWindowDelegate: WindowDelegate = WindowDelegate()

  func applicationDidFinishLaunching(_ notification: Notification) {

    // Main Window
    let mainSize: CGSize = CGSize(
      width: viewWidth, height: viewHeight)
    mainWindow.setContentSize(mainSize)
    mainWindow.styleMask = [.closable, .miniaturizable, .titled]
    mainWindow.delegate = mainWindowDelegate
    mainWindow.title = "SyphonWeb"

    // Create state object and init Metal objects
    let state: WebViewState = WebViewState()
    state.frameServer = server
    state.initMetal(width: viewWidth / mainWindow.backingScaleFactor, height: viewHeight / mainWindow.backingScaleFactor, scaleFactor: mainWindow.backingScaleFactor)

    let mainViewInst = MainView(state: state)
    let mainView: NSHostingView<MainView> = NSHostingView(rootView: mainViewInst)
    mainView.frame = CGRect(origin: .zero, size: mainSize)
    mainView.autoresizingMask = [.height, .width]
    mainWindow.contentView!.addSubview(mainView)
    mainWindow.center()
    mainWindow.makeKeyAndOrderFront(mainWindow)

    // Utility Window
    let utilitySize: CGSize = CGSize(
      width: 800 / mainWindow.backingScaleFactor, height: 300 / mainWindow.backingScaleFactor)
    utilityWindow.setContentSize(utilitySize)
    utilityWindow.styleMask = [.titled]
    utilityWindow.delegate = utilityWindowDelegate
    utilityWindow.title = "Settings"

    let utilityViewInst = UtilityView(onNavigate: { url in
      mainViewInst.navigateTo(urlString: url)
    })
    
    let utilityView: NSHostingView<UtilityView> = NSHostingView(rootView: utilityViewInst)
    utilityView.frame = CGRect(
      origin: .zero,
      size: utilitySize)
    utilityWindow.contentView!.addSubview(utilityView)
    utilityWindow.makeKeyAndOrderFront(utilityWindow)

    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
  }
}

// Start!
let app: NSApplication = NSApplication.shared
let delegate: AppDelegate = AppDelegate()
app.delegate = delegate
app.run()
