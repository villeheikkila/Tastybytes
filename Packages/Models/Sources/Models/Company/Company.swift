import Foundation
public import Tagged

public enum Company {}

public extension Company {
    typealias Id = Tagged<Company, Int>
}

public protocol CompanyLogoProtocol {
    var logos: [ImageEntity.Saved] { get }
}

public extension CompanyLogoProtocol {
    func getLogoUrl(baseUrl: URL) -> URL? {
        guard let logo = logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: baseUrl)
    }
}

public protocol CompanyProtocol: Hashable, Sendable, CompanyLogoProtocol, Verifiable {
    var id: Company.Id { get }
    var name: String { get }
    var isVerified: Bool { get }
    var logos: [ImageEntity.Saved] { get }
}
