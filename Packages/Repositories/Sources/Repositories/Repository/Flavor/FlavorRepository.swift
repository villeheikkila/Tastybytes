import Models

public protocol FlavorRepository {
    func getAll() async -> Result<[Flavor], Error>
    func insert(newFlavor: Flavor.NewRequest) async -> Result<Flavor, Error>
    func delete(id: Int) async -> Result<Void, Error>
}
