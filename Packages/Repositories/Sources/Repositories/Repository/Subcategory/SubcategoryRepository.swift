import Models

public protocol SubcategoryRepository: Sendable {
    func insert(newSubcategory: Subcategory.NewRequest) async throws -> Subcategory.Saved
    func getDetailed(id: Subcategory.Id) async throws -> Subcategory.Detailed
    func delete(id: Subcategory.Id) async throws
    func update(updateRequest: Subcategory.UpdateRequest) async throws
    func verification(id: Subcategory.Id, isVerified: Bool) async throws
}
