import Foundation
import Models

public enum MarkedAsDuplicateFilter: Sendable, Hashable {
    case id(Int)
    case all
}

public protocol ProductRepository: Sendable {
    func search(searchTerm: String, filter: Product.Filter?) async throws -> [Product.Joined]
    func search(barcode: Barcode) async throws -> [Product.Joined]
    func getById(id: Int) async throws -> Product.Joined
    func getDetailed(id: Int) async throws -> Product.Detailed
    func deleteProductDuplicateSuggestion(_ duplicateSuggestion: Product.DuplicateSuggestion) async throws
    func getByProfile(id: UUID) async throws -> [Product.Joined]
    func getFeed(_ type: Product.FeedType, from: Int, to: Int, categoryFilterId: Int?) async throws -> [Product.Joined]
    func delete(id: Int) async throws
    func create(newProductParams: Product.NewRequest) async throws -> Product.Joined
    func getUnverified() async throws -> [Product.Joined]
    func checkIfOnWishlist(id: Int) async throws -> Bool
    func removeFromWishlist(productId: Int) async throws
    func getWishlistItems(profileId: UUID) async throws -> [ProfileWishlist.Joined]
    func addToWishlist(productId: Int) async throws
    func uploadLogo(productId: Int, data: Data) async throws -> ImageEntity
    func getSummaryById(id: Int) async throws -> Summary
    func getMarkedAsDuplicateProducts(filter: MarkedAsDuplicateFilter) async throws -> [Product.DuplicateSuggestion]
    func getCreatedByUserId(id: UUID) async throws -> [Product.Joined]
    func mergeProducts(productId: Int, toProductId: Int) async throws
    func markAsDuplicate(productId: Int, duplicateOfProductId: Int) async throws
    func editProduct(productEditParams: Product.EditRequest) async throws -> Product.Joined
    func createUpdateSuggestion(productEditSuggestionParams: Product.EditSuggestionRequest) async throws
    func verification(id: Int, isVerified: Bool) async throws
    func deleteEditSuggestion(editSuggestion: Product.EditSuggestion) async throws
    func resolveEditSuggestion(editSuggestion: Product.EditSuggestion) async throws
}
