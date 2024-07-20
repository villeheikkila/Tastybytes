import Models

public protocol ServingStyleRepository: Sendable {
    func getAll() async throws -> [ServingStyle]
    func insert(servingStyle: ServingStyle.NewRequest) async throws -> ServingStyle
    func update(update: ServingStyle.UpdateRequest) async throws -> ServingStyle
    func delete(id: ServingStyle.Id) async throws
}
