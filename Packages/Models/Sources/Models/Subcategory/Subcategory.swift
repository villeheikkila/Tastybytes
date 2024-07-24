import Extensions
import Foundation
public import Tagged

public enum Subcategory {}

public extension Subcategory {
    typealias Id = Tagged<Subcategory, Int>
}

public protocol SubcategoryProtocol: Verifiable {
    var id: Subcategory.Id { get }
    var name: String { get }
    var isVerified: Bool { get }
}
