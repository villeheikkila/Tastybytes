import Foundation
import Models

public protocol BrandRepository: Sendable {
    func getById(id: Brand.Id) async throws -> Brand.JoinedSubBrandsProducts
    func getJoinedById(id: Brand.Id) async throws -> Brand.JoinedSubBrandsProductsCompany
    func getDetailed(id: Brand.Id) async throws -> Brand.Detailed
    func getByBrandOwnerId(brandOwnerId: Company.Id) async throws -> [Brand.JoinedSubBrands]
    func getAll() async throws -> [Brand.JoinedCompany]
    func getUnverified() async throws -> [Brand.JoinedSubBrandsProductsCompany]
    func getSummaryById(id: Brand.Id) async throws -> Summary
    func insert(newBrand: Brand.NewRequest) async throws -> Brand.JoinedSubBrands
    func isLikedByCurrentUser(id: Brand.Id) async throws -> Bool
    func likeBrand(brandId: Brand.Id) async throws
    func unlikeBrand(brandId: Brand.Id) async throws
    func update(updateRequest: Brand.UpdateRequest) async throws -> Brand.Detailed
    func editSuggestion(_ updateRequest: Brand.EditSuggestionRequest) async throws
    func verification(id: Brand.Id, isVerified: Bool) async throws
    func delete(id: Brand.Id) async throws
    func uploadLogo(brandId: Brand.Id, data: Data) async throws -> ImageEntity.Saved
    func resolveEditSuggestion(editSuggestion: Brand.EditSuggestion) async throws
    func deleteEditSuggestion(editSuggestion: Brand.EditSuggestion) async throws
    func getEditSuggestions() async throws -> [Brand.EditSuggestion]
}
