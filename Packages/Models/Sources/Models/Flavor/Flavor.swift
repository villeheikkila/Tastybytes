public import Tagged

public enum Flavor {}

public extension Flavor {
    typealias Id = Tagged<Flavor, Int>
}
