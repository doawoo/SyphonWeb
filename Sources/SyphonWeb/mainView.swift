import SwiftUI

@available(macOS 14, *)
struct MainView: View {
  @ObservedObject var state: WebViewState
  @State private var bookmarks: [Bookmark] = Bookmark.getAll()
  @State private var selectedBookmark: Bookmark?

  var body: some View {
    HSplitView {
      List(selection: $selectedBookmark) {
        // Filter favs and non-faves
        let nonFavorites = bookmarks.filter { mrk in
          !mrk.favorite
        }

        let favorites = bookmarks.filter { mrk in
          mrk.favorite
        }

        Section("Favorites") {
          ForEach(
            favorites
          ) { bookmark in
            makeBookmark(bookmark: bookmark)
          }
        }
        Section("Bookmarks") {
          ForEach(
            nonFavorites
          ) { bookmark in
            makeBookmark(bookmark: bookmark)
          }
        }
      }.listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
          VStack {
            Button(action: {
              // TODO: Add bookmark to database
            }) {
              Label("Add", systemImage: "plus")
            }
          }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(width: 200, alignment: .top)
      WebView(state: state).frame(
        minWidth: viewWidth, maxWidth: viewWidth,
        minHeight: viewHeight, maxHeight: viewHeight,
      ).scaleEffect(0.90)
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

  func refreshBookmarks() {
    bookmarks = []
    bookmarks = Bookmark.getAll()
  }

  @ViewBuilder func makeBookmark(bookmark: Bookmark) -> some View {
    let systemImageName =
      if bookmark.favorite {
        "star.fill"
      } else {
        "star"
      }

    HStack {
      Label("Favorite", systemImage: systemImageName).labelStyle(.iconOnly).onTapGesture {
        bookmark.toggleFavorite()
        refreshBookmarks()
      }
      Label(bookmark.name, systemImage: "link")

    }.onTapGesture {
      selectedBookmark = bookmark
      navigateTo(urlString: bookmark.url)
    }.tag(bookmark)

  }
}
