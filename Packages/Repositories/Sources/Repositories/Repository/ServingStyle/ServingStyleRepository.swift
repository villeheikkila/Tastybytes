import Models

public protocol ServingStyleRepository: Sendable {
    func getAll() async throws -> [ServingStyle.Saved]
    func insert(name: String) async throws -> ServingStyle.Saved
    func update(id: ServingStyle.Id, name: String) async throws -> ServingStyle.Saved
    func delete(id: ServingStyle.Id) async throws
}
