import SwiftUI

@available(macOS 14, *)
struct MainView: View {
  @ObservedObject var state: WebViewState
  @State private var bookmarks: [Bookmark] = Bookmark.getAll()
  @State private var selectedBookmark: Bookmark?
  @State private var showAddBookmark: Bool = false

  @State private var showDeleteConfirm: Bool = false
  @State private var bookmarkToDelete: Bookmark?

  @State private var newBookmarkName: String = ""
  @State private var newBookmarkUrl: String = ""

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
              showAddBookmark = true
            }) {
              Label("Add", systemImage: "plus")
            }
          }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .popover(isPresented: $showAddBookmark) {
              makeAddBookmarkView()
            }
        }.frame(width: 200, alignment: .top)
      WebView(state: state).frame(
        minWidth: viewWidth, maxWidth: viewWidth,
        minHeight: viewHeight, maxHeight: viewHeight,
      ).scaleEffect(0.90)
    }
    .confirmationDialog("Really delete this bookmark?", isPresented: $showDeleteConfirm) {
      Button("Yes") {
        Bookmark.deleteBookmark(toDelete: bookmarkToDelete!)
        refreshBookmarks()
      }
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

  @ViewBuilder func makeAddBookmarkView() -> some View {
    VStack {
      LabeledContent {
        TextField("Name", text: $newBookmarkName)
      } label: {
        Text("Name")
      }
      Spacer()
      LabeledContent {
        TextField("http://...", text: $newBookmarkUrl)
      } label: {
        Text("URL")
      }
      Button("Create") {
        let newBookmark = Bookmark(
          id: 0, url: newBookmarkUrl, name: newBookmarkName, order: 0, favorite: false)
        Bookmark.addNewBookmark(newBookmark: newBookmark)
        refreshBookmarks()

        // Clear state and hide popover
        newBookmarkName = ""
        newBookmarkUrl = ""
        showAddBookmark = false
      }
    }.frame(minWidth: 250, alignment: .leading).padding(20)
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
    }
    .tag(bookmark)
    .contextMenu {
      Button {
        showDeleteConfirm = true
        bookmarkToDelete = bookmark
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }
}
