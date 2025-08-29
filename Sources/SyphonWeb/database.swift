import FileProvider
import SQLite

@available(macOS 13.0, *)
func getDbPath() -> String {
  var appSupportUrl = FileManager.default.urls(
    for: .applicationSupportDirectory, in: .userDomainMask
  ).first
  if appSupportUrl != nil {
    appSupportUrl!.append(component: "syphon_web.sqlite")
    return appSupportUrl!.absoluteString
  } else {
    NSLog("Oops! Could not determine the application support directly, using temporary storage!!!")
    return "/tmp/syphon_web.sqlite"
  }
}

func createBookmarkTable(db: Connection) {
  // Table name
  let bookmarkTable = Table("bookmarks")

  // Unique ID for bookmark
  let id = SQLite.Expression<Int64>("id")

  // Order in which it's displayed on the sidebar
  let order = SQLite.Expression<Int64>("order")

  // Friendly name for the bookmark
  let name = SQLite.Expression<String>("name")

  // The actual URL of the bookmark
  let url = SQLite.Expression<String>("url")

  // Should we show this in the "favs" sub-section on the sidebar?
  let favorite = SQLite.Expression<Bool>("favorite")

  do {
    NSLog("Creating `bookmarks` table if not already present...")
    try db.run(
      bookmarkTable.create(ifNotExists: true) { table in
        table.column(id, primaryKey: true)
        table.column(order)
        table.column(name)
        table.column(url)
        table.column(favorite)
      })
  } catch {
    NSLog("createBookmarkTable() Error: \(error)")
  }
}

@available(macOS 13.0, *)
func initDatabase() -> Connection? {
  do {
    let dbPath = getDbPath()

    NSLog("Opening SQLite DB at path \(dbPath)")

    let db: Connection = try Connection(getDbPath())
    createBookmarkTable(db: db)

    return db
  } catch {
    NSLog("initDatabase() Error: \(error)")
    return nil
  }
}
