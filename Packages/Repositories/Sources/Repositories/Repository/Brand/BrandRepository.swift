import Foundation
import Models

public protocol BrandRepository: Sendable {
    func getById(id: Int) async -> Result<Brand.JoinedSubBrandsProducts, Error>
    func getJoinedById(id: Int) async -> Result<Brand.JoinedSubBrandsProductsCompany, Error>
    func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[Brand.JoinedSubBrands], Error>
    func getUnverified() async -> Result<[Brand.JoinedSubBrandsProductsCompany], Error>
    func getSummaryById(id: Int) async -> Result<Summary, Error>
    func insert(newBrand: Brand.NewRequest) async -> Result<Brand.JoinedSubBrands, Error>
    func isLikedByCurrentUser(id: Int) async -> Result<Bool, Error>
    func likeBrand(brandId: Int) async -> Result<Void, Error>
    func unlikeBrand(brandId: Int) async -> Result<Void, Error>
    func update(updateRequest: Brand.UpdateRequest) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func uploadLogo(brandId: Int, data: Data) async -> Result<ImageEntity, Error>
}
