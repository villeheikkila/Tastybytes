import Models

public protocol FlavorRepository: Sendable {
    func getAll() async throws -> [Flavor.Saved]
    func insert(name: String) async throws -> Flavor.Saved
    func delete(id: Flavor.Id) async throws
}
