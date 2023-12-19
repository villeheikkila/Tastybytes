import Models

public protocol SubcategoryRepository: Sendable {
    func insert(newSubcategory: Subcategory.NewRequest) async -> Result<Subcategory, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func update(updateRequest: Subcategory.UpdateRequest) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
}
