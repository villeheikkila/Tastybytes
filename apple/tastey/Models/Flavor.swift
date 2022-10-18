struct Flavor: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    
    static func == (lhs: Flavor, rhs: Flavor) -> Bool {
        return lhs.id == rhs.id
    }
}
