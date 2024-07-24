public import Tagged

public extension CheckIn {
    enum Reaction {}
}

public extension CheckIn.Reaction {
    typealias Id = Tagged<CheckIn.Reaction, Int>
}
