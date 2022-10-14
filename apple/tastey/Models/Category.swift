struct Category: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}
