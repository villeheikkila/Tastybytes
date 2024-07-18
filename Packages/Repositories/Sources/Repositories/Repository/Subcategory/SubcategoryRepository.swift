import Models

public protocol SubcategoryRepository: Sendable {
    func insert(newSubcategory: Subcategory.NewRequest) async throws -> Subcategory
    func getDetailed(id: Int) async throws -> Subcategory.Detailed
    func delete(id: Int) async throws
    func update(updateRequest: Subcategory.UpdateRequest) async throws
    func verification(id: Int, isVerified: Bool) async throws
}
