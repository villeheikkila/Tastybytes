import Models

public protocol ServingStyleRepository: Sendable {
    func getAll() async -> Result<[ServingStyle], Error>
    func insert(servingStyle: ServingStyle.NewRequest) async -> Result<ServingStyle, Error>
    func update(update: ServingStyle.UpdateRequest) async -> Result<ServingStyle, Error>
    func delete(id: Int) async -> Result<Void, Error>
}
