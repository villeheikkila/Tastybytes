import Foundation
public import Tagged

public extension Profile {
    struct Account: Codable, Hashable, Identifiable, Sendable {
        public let id: Profile.Id
        public let email: String?

        public init(id: Profile.Id, email: String? = nil) {
            self.id = id
            self.email = email
        }
    }
}
