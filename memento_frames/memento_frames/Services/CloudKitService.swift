import Foundation
import CloudKit

/// A service that interfaces with the iCloud private database using CloudKit APIs
class CloudKitService {
    static let shared = CloudKitService()
    
    // Use the default container and private database
    private let container = CKContainer.default()
    private var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }
    
    private init() {}
    
    /// Checks the user's iCloud account status
    func checkAccountStatus() async -> CKAccountStatus {
        do {
            return try await container.accountStatus()
        } catch {
            print("Error checking iCloud account status: \(error.localizedDescription)")
            return .couldNotDetermine
        }
    }
    
    /// Save or update a CloudKit record
    func save(_ record: CKRecord) async throws {
        try await privateDatabase.save(record)
    }
    
    /// Batch save or update CloudKit records
    func save(_ records: [CKRecord]) async throws {
        guard !records.isEmpty else { return }
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        
        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            privateDatabase.add(operation)
        }
    }
    
    /// Fetch all records of a specific type
    func fetchAll(recordType: String) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        return try await withCheckedThrowingContinuation { continuation in
            var fetchedRecords: [CKRecord] = []
            
            // Standard query operation
            let operation = CKQueryOperation(query: query)
            operation.recordMatchedBlock = { _, recordResult in
                if let record = try? recordResult.get() {
                    fetchedRecords.append(record)
                }
            }
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume(returning: fetchedRecords)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            privateDatabase.add(operation)
        }
    }
    
    /// Delete a record from CloudKit database
    func delete(recordID: CKRecord.ID) async throws {
        _ = try await privateDatabase.deleteRecord(withID: recordID)
    }
}
