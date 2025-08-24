import SwiftUI

struct MainView: View {
  var body: some View {
    GeometryReader { geometry in
      WebView(url: URL(string: "https://puppy.surf")!).frame(
        minWidth: geometry.size.width, maxWidth: geometry.size.width,
        minHeight: geometry.size.height, maxHeight: geometry.size.height)
    }

  }
}
