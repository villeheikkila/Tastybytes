import Foundation
public import Tagged

public enum Company {}

public extension Company {
    typealias Id = Tagged<Company, Int>
}

public protocol CompanyLogoProtocol {
    var logos: [ImageEntity.Saved] { get }
}

public protocol CompanyProtocol: Hashable, Sendable, CompanyLogoProtocol, Verifiable {
    var id: Company.Id { get }
    var name: String { get }
    var isVerified: Bool { get }
    var logos: [ImageEntity.Saved] { get }
}
