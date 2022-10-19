import Foundation

struct Company: Identifiable, Decodable {
    let id: Int
    let name: String
}

extension Company: Hashable {
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.id == rhs.id
    }
}

struct NewCompany: Encodable {
    let name: String
}

