import Foundation
import Models

public protocol RoleRepository: Sendable {
    func getRoles() async throws -> [Role.Joined]
    func addProfileForProfile(profile: Profile.Saved, role: Role.Joined) async throws
    func removeProfileFromProfile(profile: Profile.Saved, role: Role.Joined) async throws
}
