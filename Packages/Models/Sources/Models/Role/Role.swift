public import Tagged

public enum Role {}

public extension Role {
    typealias Id = Tagged<Role, Int>
}
