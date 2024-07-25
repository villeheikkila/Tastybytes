public import Tagged

public enum Country {}

public extension Country {
    typealias Id = Tagged<Country, String>
}
