public extension Role {
    enum Name: String, Codable, Sendable {
        case admin
        case user
        case moderator
        case pro
        case superAdmin = "super_admin"
    }
}
