import Foundation
public import Tagged

public enum Brand {}

public extension Brand {
    typealias Id = Tagged<Brand, Int>
}

public protocol BrandProtocol: Verifiable {
    var id: Brand.Id { get }
    var name: String { get }
    var logos: [ImageEntity.Saved] { get }
    var isVerified: Bool { get }
}

public extension BrandProtocol {
    func getLogoUrl(baseUrl: URL) -> URL? {
        guard let logo = logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: baseUrl)
    }
}
