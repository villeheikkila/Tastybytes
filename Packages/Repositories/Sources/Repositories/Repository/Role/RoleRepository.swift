import Foundation
import Models

public protocol RoleRepository: Sendable {
    func getRoles() async throws -> [Role.Joined]
    func addRoleForProfile(profile: Profile.Saved, role: Role.Joined) async throws
    func removeRoleFromProfile(profile: Profile.Saved, role: Role.Joined) async throws
}
