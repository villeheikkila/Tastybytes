import Foundation

public enum VerifiableEntity: Identifiable, Hashable {
    case product(Product.Joined)
    case brand(Brand.JoinedSubBrandsCompany)
    case subBrand(SubBrand.JoinedBrand)
    case company(Company.Saved)

    public var id: Int {
        hashValue
    }
}
