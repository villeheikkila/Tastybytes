import Extensions
import Foundation
public import Tagged

public extension Product {
    enum Barcode {}
}

public extension Product.Barcode {
    typealias Id = Tagged<Product.Barcode, Int>
}
