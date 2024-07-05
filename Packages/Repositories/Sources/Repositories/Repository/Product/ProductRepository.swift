import Foundation
import Models

public enum MarkedAsDuplicateFilter: Sendable, Hashable {
    case id(Int)
    case all
}

public protocol ProductRepository: Sendable {
    func search(searchTerm: String, filter: Product.Filter?) async -> Result<[Product.Joined], Error>
    func search(barcode: Barcode) async -> Result<[Product.Joined], Error>
    func getById(id: Int) async -> Result<Product.Joined, Error>
    func getDetailed(id: Int) async -> Result<Product.Joined, Error>
    func getByProfile(id: UUID) async -> Result<[Product.Joined], Error>
    func getFeed(_ type: Product.FeedType, from: Int, to: Int, categoryFilterId: Int?) async
        -> Result<[Product.Joined], Error>
    func delete(id: Int) async -> Result<Void, Error>
    func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error>
    func getUnverified() async -> Result<[Product.Joined], Error>
    func checkIfOnWishlist(id: Int) async -> Result<Bool, Error>
    func removeFromWishlist(productId: Int) async -> Result<Void, Error>
    func getWishlistItems(profileId: UUID) async -> Result<[ProfileWishlist.Joined], Error>
    func addToWishlist(productId: Int) async -> Result<Void, Error>
    func uploadLogo(productId: Int, data: Data) async -> Result<ImageEntity, Error>
    func getSummaryById(id: Int) async -> Result<Summary, Error>
    func getMarkedAsDuplicateProducts(filter: MarkedAsDuplicateFilter) async -> Result<[ProductDuplicateSuggestion], Error>
    func getCreatedByUserId(id: UUID) async -> Result<[Product.Joined], Error>
    func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error>
    func markAsDuplicate(productId: Int, duplicateOfProductId: Int) async -> Result<Void, Error>
    func editProduct(productEditParams: Product.EditRequest) async -> Result<Product.Joined, Error>
    func createUpdateSuggestion(productEditSuggestionParams: Product.EditSuggestionRequest) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
}
