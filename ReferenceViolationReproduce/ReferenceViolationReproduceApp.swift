import SQLiteData
import SwiftUI

@Table nonisolated struct Parent: Identifiable {
    let id: UUID
    var payload: Data
}

@Table("children") nonisolated struct Child: Identifiable {
    let id: UUID
    var parentID: Parent.ID
}

@main
struct ReferenceViolationReproduceApp: App {
    init() {
        try! prepareDependencies {
            var configuration = Configuration()
            configuration.prepareDatabase { try $0.attachMetadatabase() }
            let database = try SQLiteData.defaultDatabase(configuration: configuration)
            var migrator = DatabaseMigrator()
            migrator.registerMigration("Create tables") { db in
                try #sql(
                    """
                    CREATE TABLE "parents" (
                      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                      "payload" BLOB NOT NULL
                    ) STRICT
                    """
                )
                .execute(db)
                try #sql(
                    """
                    CREATE TABLE "children" (
                      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                      "parentID" TEXT NOT NULL REFERENCES "parents"("id") ON DELETE CASCADE
                    ) STRICT
                    """
                )
                .execute(db)
            }
            try migrator.migrate(database)
            $0.defaultDatabase = database
            $0.defaultSyncEngine = try SyncEngine(for: database, tables: Parent.self, Child.self)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
