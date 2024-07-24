public import Tagged

public enum ServingStyle {}

public extension ServingStyle {
    typealias Id = Tagged<ServingStyle, Int>
}
