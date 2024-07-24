public import Tagged

public enum Permission {}

public extension Permission {
    typealias Id = Tagged<Permission, Int>
}
