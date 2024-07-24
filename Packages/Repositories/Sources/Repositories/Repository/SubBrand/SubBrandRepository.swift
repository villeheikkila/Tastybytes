import Models

public protocol SubBrandRepository: Sendable {
    func insert(newSubBrand: SubBrand.NewRequest) async throws -> SubBrand.Saved
    func getDetailed(id: SubBrand.Id) async throws -> SubBrand.Detailed
    @discardableResult func update(updateRequest: SubBrand.Update) async throws -> SubBrand.Saved
    func delete(id: SubBrand.Id) async throws
    func verification(id: SubBrand.Id, isVerified: Bool) async throws
    func getUnverified() async throws -> [SubBrand.JoinedBrand]
    func deleteEditSuggestion(editSuggestion: SubBrand.EditSuggestion) async throws
    func createEditSuggestion(id: SubBrand.Id, brand: BrandProtocol?, name: String?, includesBrandName: Bool?) async throws
    func getEditSuggestions() async throws -> [SubBrand.EditSuggestion]
}
