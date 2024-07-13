import Foundation
import Models

public protocol BrandRepository: Sendable {
    func getById(id: Int) async throws -> Brand.JoinedSubBrandsProducts
    func getJoinedById(id: Int) async throws -> Brand.JoinedSubBrandsProductsCompany
    func getDetailed(id: Int) async throws -> Brand.JoinedSubBrandsProductsCompany
    func getByBrandOwnerId(brandOwnerId: Int) async throws -> [Brand.JoinedSubBrands]
    func getUnverified() async throws -> [Brand.JoinedSubBrandsProductsCompany]
    func getSummaryById(id: Int) async throws -> Summary
    func insert(newBrand: Brand.NewRequest) async throws -> Brand.JoinedSubBrands
    func isLikedByCurrentUser(id: Int) async throws -> Bool
    func likeBrand(brandId: Int) async throws
    func unlikeBrand(brandId: Int) async throws
    func update(updateRequest: Brand.UpdateRequest) async throws -> Brand.JoinedSubBrandsProductsCompany
    func verification(id: Int, isVerified: Bool) async throws
    func delete(id: Int) async throws
    func uploadLogo(brandId: Int, data: Data) async throws -> ImageEntity
}
