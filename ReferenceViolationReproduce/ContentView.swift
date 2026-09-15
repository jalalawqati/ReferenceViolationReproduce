import CloudKit
import SQLiteData
import SwiftUI

struct ContentView: View {
    @FetchAll var parents: [Parent]
    @FetchAll var children: [Child]
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.defaultSyncEngine) var syncEngine

    var body: some View {
        Form {
            Text("Parents: \(parents.count)")
            Text("Children: \(children.count)")
            Button("1. Add parent") {
                var payload = Data(count: 10_000_000)
                payload.withUnsafeMutableBytes { _ = SecRandomCopyBytes(kSecRandomDefault, $0.count, $0.baseAddress!) }
                save { try Parent.insert { Parent.Draft(payload: payload) }.execute($0) }
            }
            Button("2. Add child to last parent") {
                guard let parentID = parents.last?.id else { return }
                save { try Child.insert { Child.Draft(parentID: parentID) }.execute($0) }
            }
            Button("Delete everything in CloudKit", role: .destructive) {
                Task {
                    try? await CKContainer(identifier: "iCloud.com.ReferenceViolationReproduce")
                        .privateCloudDatabase
                        .deleteRecordZone(withID: CKRecordZone.ID(zoneName: "co.pointfree.SQLiteData.defaultZone"))
                    try? await syncEngine.fetchChanges()
                }
            }
        }
    }

    private func save(_ write: @escaping @Sendable (Database) throws -> Void) {
        Task {
            try await database.write(write)
            try? await syncEngine.sendChanges()
        }
    }
}
