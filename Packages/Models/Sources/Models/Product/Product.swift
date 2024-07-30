import Foundation
public import Tagged

public enum Product {}

public extension Product {
    typealias Id = Tagged<Product, Int>
}

public protocol ProductLogoProtocol {
    var logos: [ImageEntity.Saved] { get }
}

public protocol ProductProtocol: ProductLogoProtocol, Verifiable {
    var id: Product.Id { get }
    var name: String? { get }
    var description: String? { get }
    var isVerified: Bool { get }
    var subBrand: SubBrand.JoinedBrand { get }
    var category: Category.Saved { get }
    var subcategories: [Subcategory.Saved] { get }
    var isDiscontinued: Bool { get }
}
