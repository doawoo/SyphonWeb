import SQLite
import SwiftUI

@available(macOS 14, *)
@Observable
class Bookmark: Identifiable, Hashable {

  public var id: Int64
  public var url: String
  public var name: String
  public var order: Int64
  public var favorite: Bool

  internal init(id: Int64, url: String, name: String, order: Int64, favorite: Bool) {
    self.id = id
    self.url = url
    self.name = name
    self.order = order
    self.favorite = favorite
  }

  internal init(fromRowElement: RowIterator.Element) {
    let id = SQLite.Expression<Int64>("id")
    let order = SQLite.Expression<Int64>("order")
    let name = SQLite.Expression<String>("name")
    let url = SQLite.Expression<String>("url")
    let favorite = SQLite.Expression<Bool>("favorite")

    do {
      try self.id = fromRowElement.get(id)
      try self.url = fromRowElement.get(url)
      try self.name = fromRowElement.get(name)
      try self.order = fromRowElement.get(order)
      try self.favorite = fromRowElement.get(favorite)
    } catch {
      NSLog("Error create bookmark object from DB!")
      self.id = -1
      self.url = "about:blank"
      self.name = "<Invalid>"
      self.order = -1
      self.favorite = false
    }
  }

  // Hashable
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
    hasher.combine(self.url)
    hasher.combine(self.name)
    hasher.combine(self.order)
    hasher.combine(self.favorite)
  }

  // Equality and sorting
  static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
    lhs.id == rhs.id
  }

  static func > (lhs: Bookmark, rhs: Bookmark) -> Bool {
    lhs.order > rhs.order
  }

  static func < (lhs: Bookmark, rhs: Bookmark) -> Bool {
    lhs.order < rhs.order
  }

  public func toggleFavorite() {
    let bookmarks = Table("bookmarks")
    let id = SQLite.Expression<Int64>("id")
    let favorite = SQLite.Expression<Bool>("favorite")
    let mrk = bookmarks.filter(id == self.id)

    self.favorite = !self.favorite
    let query = mrk.update(favorite <- self.favorite)

    do {
      try databaseConn!.run(query)
    } catch {
      NSLog("Error updating bookmark favorite: \(error)")
    }
  }

  public func updateName(newName: String) {
    let bookmarks = Table("bookmarks")
    let id = SQLite.Expression<Int64>("id")
    let name = SQLite.Expression<String>("name")
    let mrk = bookmarks.filter(id == self.id)

    self.name = newName
    let query = mrk.update(name <- self.name)
    do {
      try databaseConn!.run(query)
      self.name = newName
    } catch {
      NSLog("Error updating bookmark name: \(error)")
    }
  }

  public func updateUrl(newUrl: String) {
    let bookmarks = Table("bookmarks")
    let id = SQLite.Expression<Int64>("id")
    let url = SQLite.Expression<String>("url")
    let mrk = bookmarks.filter(id == self.id)

    self.url = newUrl
    let query = mrk.update(url <- self.url)
    do {
      try databaseConn!.run(query)
      self.url = newUrl
    } catch {
      NSLog("Error updating bookmark URL: \(error)")
    }
  }

  // Static utility functions

  public static func getAll() -> [Bookmark] {
    do {
      let bookmarks = SQLite.Table("bookmarks")
      let itr: RowIterator? = try databaseConn?.prepareRowIterator(bookmarks)
      let bookmarksFound = try itr?.map { row in
        Bookmark.init(fromRowElement: row)
      }

      return bookmarksFound!
    } catch {
      NSLog("Error fetching bookmarks from database: \(error)")
      return []
    }
  }

  public static func getById(bookmarkId: Int64) -> Bookmark? {
    do {
      let bookmarks = SQLite.Table("bookmarks")

      let id = SQLite.Expression<Int64>("id")
      let query: SQLite.Table = bookmarks.filter(id == bookmarkId).limit(1)
      let itr: RowIterator? = try databaseConn?.prepareRowIterator(query)

      let found = itr?.next()

      if found != nil {
        return Bookmark(fromRowElement: found!)
      }

      return nil

    } catch {
      NSLog("Error fetching bookmark from database: \(error)")
      return nil
    }
  }

  public static func addNewBookmark(newBookmark: Bookmark) {
    let bookmarks = SQLite.Table("bookmarks")
    let order = SQLite.Expression<Int64>("order")
    let name = SQLite.Expression<String>("name")
    let url = SQLite.Expression<String>("url")
    let favorite = SQLite.Expression<Bool>("favorite")
    let query = bookmarks.insert(
      order <- 0, name <- newBookmark.name, url <- newBookmark.url, favorite <- false)

    do {
      try databaseConn!.run(query)
    } catch {
      NSLog("Error creating bookmark: \(error)")
    }
  }

  public static func deleteBookmark(toDelete: Bookmark) {
    let bookmarks = SQLite.Table("bookmarks")
    let id = SQLite.Expression<Int64>("id")
    let query = bookmarks.filter(id == toDelete.id).delete()

    do {
      try databaseConn!.run(query)
    } catch {
      NSLog("Error deleting bookmark: \(error)")
    }
  }
}
