
struct Brand: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let companies: Company

    static func == (lhs: Brand, rhs: Brand) -> Bool {
        return lhs.id == rhs.id
    }
}
