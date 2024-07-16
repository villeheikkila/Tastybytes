import Foundation
import Models

public protocol RoleRepository: Sendable {
    func getRoles() async throws -> [Role]
    func addProfileForProfile(profile: Profile, role: Role) async throws
    func removeProfileFromProfile(profile: Profile, role: Role) async throws
}
