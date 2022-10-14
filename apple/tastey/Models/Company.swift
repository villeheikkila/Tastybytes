import Foundation

struct Company: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String

    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.id == rhs.id
    }
}

struct NewCompany: Encodable {
    let name: String
}

