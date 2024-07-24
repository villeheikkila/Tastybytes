import Foundation
public import Tagged

public enum SubBrand {}

public extension SubBrand {
    typealias Id = Tagged<SubBrand, Int>
}

public protocol SubBrandProtocol: Verifiable {
    var id: SubBrand.Id { get }
    var name: String? { get }
    var includesBrandName: Bool { get }
    var isVerified: Bool { get }
}
