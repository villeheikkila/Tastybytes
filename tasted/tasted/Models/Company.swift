import Foundation

struct NewCompany: Codable {
    let name: String
}

struct Company: Identifiable, Codable {
    let id: Int?
    let name: String
    let created_at: String?
    let created_by: String?
    let logo_url: String?
}


