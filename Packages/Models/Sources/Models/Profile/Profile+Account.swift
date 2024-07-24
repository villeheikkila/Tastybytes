import Foundation
public import Tagged

public extension Profile {
    struct Account: Codable, Hashable, Identifiable, Sendable {
        public var id: Profile.Id
        public var email: String?

        public init(id: Profile.Id, email: String? = nil) {
            self.id = id
            self.email = email
        }
    }
}
