import Foundation
public import Tagged

public enum Brand {}

public extension Brand {
    typealias Id = Tagged<Brand, Int>
}

public protocol BrandProtocol: Verifiable {
    var id: Brand.Id { get }
    var name: String { get }
    var logos: [Logo.Saved] { get }
    var isVerified: Bool { get }
}
