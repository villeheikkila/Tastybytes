import Foundation

public struct Profile: Identifiable, Codable {
    public let id: UUID
    let first_name: String?
    let last_name: String?
    let username: String
    let avatar_url: String?
}

struct ProfileUpdate: Codable {
    let username: String
    let first_name: String?
    let last_name: String?
}
