import Foundation

struct SupabaseCheckInReactionsRepository {
    private let tableName = "check_in_reactions"
    private let joinedWithProfile = "id, created_by, profiles (id, username, avatar_url)"
    
    func insert(newCheckInReaction: NewCheckInReaction) async throws -> CheckInReaction {
        return try await Supabase.client.database.from(tableName)
            .insert(values: newCheckInReaction, returning: .representation)
            .select(columns: joinedWithProfile)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CheckInReaction.self)
    }
    
    func deleteById(id: Int) async throws -> Void {
        try await Supabase.client.database.from(tableName)
            .delete().eq(column: "id", value: id)
            .execute()
    }
}
