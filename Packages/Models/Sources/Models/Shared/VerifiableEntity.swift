import Foundation

public enum VerifiableEntity: Identifiable, Hashable {
    case product(Product.Joined)
    case brand(Brand.JoinedSubBrandsProductsCompany)
    case subBrand(SubBrand.JoinedBrand)
    case company(Company)

    public var id: Int {
        hashValue
    }
}
