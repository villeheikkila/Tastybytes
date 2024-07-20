import Foundation
import Models
internal import Supabase

struct SupabaseRoleRepository: RoleRepository {
    let client: SupabaseClient

    func getRoles() async throws -> [Role] {
        try await client
            .from(.roles)
            .select(Role.getQuery(.joined(false)))
            .execute()
            .value
    }

    func removeProfileFromProfile(profile: Profile, role: Role) async throws {
        try await client
            .from(.profilesRoles)
            .delete()
            .eq("profile_id", value: profile.id.rawValue)
            .eq("role_id", value: role.id.rawValue)
            .execute()
            .value
    }

    func addProfileForProfile(profile: Profile, role: Role) async throws {
        struct AddPermissionRequest: Encodable {
            let roleId: Role.Id
            let profileId: Profile.Id

            init(role: Role, profile: Profile) {
                roleId = role.id
                profileId = profile.id
            }

            enum CodingKeys: String, CodingKey, CaseIterable {
                case roleId = "role_id"
                case profileId = "profile_id"
            }
        }
        return try await client
            .from(.profilesRoles)
            .insert(AddPermissionRequest(role: role, profile: profile))
            .execute()
            .value
    }
}
