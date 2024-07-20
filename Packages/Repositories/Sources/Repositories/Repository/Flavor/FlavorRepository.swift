import Models

public protocol FlavorRepository: Sendable {
    func getAll() async throws -> [Flavor]
    func insert(newFlavor: Flavor.NewRequest) async throws -> Flavor
    func delete(id: Flavor.Id) async throws
}
