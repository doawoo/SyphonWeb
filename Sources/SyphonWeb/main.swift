import AppKit
import SwiftUI
import MetalKit
import Syphon

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
    let window: NSWindow = NSWindow()
    let windowDelegate: WindowDelegate = WindowDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let size: CGSize = CGSize(width: 1920 / window.backingScaleFactor, height: 1080 / window.backingScaleFactor)
        window.setContentSize(size)
        window.styleMask = [.closable, .miniaturizable, .titled]
        window.delegate = windowDelegate
        window.title = "SyphonWeb"

        let view: NSHostingView<MainView> = NSHostingView(rootView: MainView())
        view.frame = CGRect(origin: .zero, size: size)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        window.center()
        window.makeKeyAndOrderFront(window)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// Start!
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()