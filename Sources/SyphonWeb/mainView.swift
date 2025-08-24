import SwiftUI

struct MainView: View {
  @ObservedObject var state: WebViewState

  var body: some View {
    GeometryReader { geometry in
      WebView(state: state).frame(
        minWidth: geometry.size.width, maxWidth: geometry.size.width,
        minHeight: geometry.size.height, maxHeight: geometry.size.height)
    }
  }

  func navigateTo(urlString: String) {
    if var urlToNavigate = URL(string: urlString) {
      if urlToNavigate.scheme == nil {
        if let httpsURL = URL(string: "https://" + urlString) {
          urlToNavigate = httpsURL
        }
      }
      
      state.url = urlToNavigate
    }
  }
}