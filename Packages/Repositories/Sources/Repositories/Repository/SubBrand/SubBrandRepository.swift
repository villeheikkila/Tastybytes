import Models

public protocol SubBrandRepository: Sendable {
    func insert(newSubBrand: SubBrand.NewRequest) async throws -> SubBrand
    func getDetailed(id: Int) async throws -> SubBrand.Detailed
    @discardableResult func update(updateRequest: SubBrand.Update) async throws -> SubBrand
    func delete(id: Int) async throws
    func verification(id: Int, isVerified: Bool) async throws
    func getUnverified() async throws -> [SubBrand.JoinedBrand]
}
