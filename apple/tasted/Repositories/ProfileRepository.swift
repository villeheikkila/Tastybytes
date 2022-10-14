import Foundation

protocol ProfileRepository {
    func loadProfileById(profileId: String) async throws -> Profile
}

struct SupabaseProfileRepository: ProfileRepository {
    func loadProfileById(profileId: String) async throws -> Profile {
        let profileQuery = API.supabase.database
            .from("profiles")
            .select(columns: "*", count: .exact)
            .eq(column: "id", value: profileId)
            .limit(count: 1)
            .single()
        
        return try await profileQuery.execute().decoded(to: Profile.self)
    }
}
