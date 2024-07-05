import Models

public protocol SubBrandRepository: Sendable {
    func insert(newSubBrand: SubBrand.NewRequest) async -> Result<SubBrand, Error>
    func getDetailed(id: Int) async -> Result<SubBrand.JoinedProduct, Error>
    func update(updateRequest: SubBrand.Update) async -> Result<SubBrand, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
    func getUnverified() async -> Result<[SubBrand.JoinedBrand], Error>
}
