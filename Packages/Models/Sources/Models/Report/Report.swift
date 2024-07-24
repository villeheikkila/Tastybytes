import Foundation
public import Tagged

public enum Report {}

public extension Report {
    typealias Id = Tagged<Report, Int>
}

public extension Report {
    enum Content: Hashable, Sendable {
        case product(Product.Joined)
        case company(Company.Saved)
        case brand(Brand.JoinedSubBrandsProductsCompany)
        case subBrand(SubBrand.JoinedBrand)
        case checkIn(CheckIn)
        case comment(CheckInComment.Joined)
        case checkInImage(ImageEntity.JoinedCheckIn)
        case profile(Profile)
        case location(Location.Saved)
    }
}
