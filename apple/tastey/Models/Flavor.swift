struct Flavor: Identifiable, Decodable {
    let id: Int
    let name: String
}

extension Flavor: Hashable {
    static func == (lhs: Flavor, rhs: Flavor) -> Bool {
        return lhs.id == rhs.id
    }
}
