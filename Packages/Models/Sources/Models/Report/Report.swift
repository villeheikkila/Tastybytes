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
        case brand(Brand.JoinedSubBrandsCompany)
        case subBrand(SubBrand.JoinedBrand)
        case checkIn(CheckIn.Joined)
        case comment(CheckIn.Comment.Joined)
        case checkInImage(ImageEntity.CheckInId)
        case profile(Profile.Saved)
        case location(Location.Saved)
    }
}
