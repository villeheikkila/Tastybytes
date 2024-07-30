import Foundation
public import Tagged

public extension Profile {
    struct Account: Codable, Hashable, Identifiable, Sendable {
        public let id: Profile.Id
        public let email: String?
        public let roles: [Role.Name]
        public let permissions: [Permission.Name]

        public init(id: Profile.Id, email: String? = nil, roles: [Role.Name], permissions: [Permission.Name]) {
            self.id = id
            self.email = email
            self.roles = roles
            self.permissions = permissions
        }
    }
}
