import AppKit
import MetalKit
import SwiftUI
import Syphon

// Stop app from napping
var activity: NSObjectProtocol?
activity = ProcessInfo().beginActivity(
  options: ProcessInfo.ActivityOptions.userInitiated, reason: "No Napping!")

// Init metal, syphon and SQLite
NSLog("Creating Metal device and Syphon server...")
let viewWidth = 1280.0
let viewHeight = 720.0
let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice()!
let server: SyphonMetalServer = SyphonMetalServer.init(name: "SyphonWeb", device: metalDevice)

NSLog("Opening SQLite database connection...")
nonisolated(unsafe) let databaseConn = initDatabase()

// AppKit Stuff
class WindowDelegate: NSObject, NSWindowDelegate {

  func windowWillClose(_ notification: Notification) {
    NSApplication.shared.terminate(0)
  }
}

@available(macOS 14, *)
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  let mainWindow: NSWindow = NSWindow()
  let mainWindowDelegate: WindowDelegate = WindowDelegate()

  func applicationDidFinishLaunching(_ notification: Notification) {

    // Main Window
    let mainSize: CGSize = CGSize(
      width: viewWidth + 200, height: viewHeight)
    mainWindow.setContentSize(mainSize)
    mainWindow.styleMask = [.closable, .titled]
    mainWindow.delegate = mainWindowDelegate
    mainWindow.title = "SyphonWeb"

    // Create state object and init Metal objects
    let state: WebViewState = WebViewState()
    state.frameServer = server
    state.initMetal(
      width: viewWidth / mainWindow.backingScaleFactor,
      height: viewHeight / mainWindow.backingScaleFactor, scaleFactor: mainWindow.backingScaleFactor
    )

    let mainViewInst = MainView(state: state)
    let mainView: NSHostingView<MainView> = NSHostingView(rootView: mainViewInst)
    mainView.frame = CGRect(origin: .zero, size: mainSize)
    mainView.autoresizingMask = [.height, .width]
    mainWindow.contentView!.addSubview(mainView)
    mainWindow.center()
    mainWindow.makeKeyAndOrderFront(mainWindow)

    setupAppMenu()

    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func setupAppMenu() {
    let mainMenu = NSMenu()
    let appMenuItem = NSMenuItem()
    let appMenu = NSMenu()

    appMenu.addItem(
      NSMenuItem(
        title: "About SyphonWeb", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
        keyEquivalent: ""))
    appMenu.addItem(NSMenuItem.separator())

    appMenu.addItem(
      NSMenuItem(
        title: "Quit SyphonWeb", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    )

    appMenuItem.submenu = appMenu
    mainMenu.addItem(appMenuItem)

    NSApp.mainMenu = mainMenu
  }
}

// Start!
if #available(macOS 14, *) {
  let app: NSApplication = NSApplication.shared
  let delegate: AppDelegate = AppDelegate()
  // Fallback on earlier versions
  app.delegate = delegate
  app.run()

} else {
  NSLog("You cannot run this app on this version of macOS!")
}
