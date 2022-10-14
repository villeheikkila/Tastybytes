
struct SubBrand: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let brands: Brand

    static func == (lhs: SubBrand, rhs: SubBrand) -> Bool {
        return lhs.id == rhs.id
    }
}
