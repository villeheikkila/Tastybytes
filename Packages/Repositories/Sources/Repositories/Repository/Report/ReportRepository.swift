import Foundation
import Models

public enum ReportFilter: Sendable, Codable, Hashable {
    case checkIn(Int)
    case product(Int)
    case company(Int)
    case brand(Int)
    case comment(Int)
    case subBrand(Int)
    case checkInImage(Int)
    case profile(UUID)

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
        }
    }
}

public protocol ReportRepository: Sendable {
    func getAll(_ filter: ReportFilter?) async throws -> [Report]
    func insert(report: Report.NewRequest) async throws
    func delete(id: Int) async throws
    @discardableResult func resolve(id: Int) async throws -> Report
}
