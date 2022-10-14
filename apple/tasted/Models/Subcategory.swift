struct Subcategory: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let categories: Category

    static func == (lhs: Subcategory, rhs: Subcategory) -> Bool {
        return lhs.id == rhs.id
    }
}
