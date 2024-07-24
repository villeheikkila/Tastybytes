import Foundation
import Models

public enum ReportFilter: Sendable, Codable, Hashable {
    case checkIn(CheckIn.Id)
    case product(Product.Id)
    case company(Company.Id)
    case brand(Brand.Id)
    case comment(CheckIn.Comment.Id)
    case subBrand(SubBrand.Id)
    case checkInImage(ImageEntity.Id)
    case profile(Profile.Id)
    case location(Location.Id)

    var column: String {
        switch self {
        case .checkIn:
            "check_in_id"
        case .product:
            "product_id"
        case .company:
            "company_id"
        case .brand:
            "brand_id"
        case .comment:
            "check_in_comment_id"
        case .subBrand:
            "sub_brand_id"
        case .checkInImage:
            "check_in_image_id"
        case .profile:
            "profile_id"
        case .location:
            "location_id"
        }
    }
}

public protocol ReportRepository: Sendable {
    func getAll(_ filter: ReportFilter?) async throws -> [Report.Joined]
    func insert(report: Report.NewRequest) async throws
    func delete(id: Report.Id) async throws
    @discardableResult func resolve(id: Report.Id) async throws -> Report.Joined
}
