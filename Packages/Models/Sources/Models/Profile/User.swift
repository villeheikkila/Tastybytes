import Foundation

public struct User: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var email: String?

    public init(id: UUID, email: String? = nil) {
        self.id = id
        self.email = email
    }
}
