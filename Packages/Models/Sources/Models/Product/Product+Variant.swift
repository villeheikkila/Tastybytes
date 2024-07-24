public import Tagged

public extension Product {
    enum Variant {}
}

public extension Product.Variant {
    typealias Id = Tagged<Product.Variant, Int>
}
