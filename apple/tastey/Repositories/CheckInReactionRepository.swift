import Foundation
import Supabase

protocol CheckInReactionsRepository {
    func insert(newCheckInReaction: NewCheckInReaction) async throws -> CheckInReaction
    func delete(id: Int) async throws -> Void
}

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient
    private let tableName = "check_in_reactions"
    private let joinedWithProfile = "id, profiles (id, username, avatar_url, name_display)"
    
    func insert(newCheckInReaction: NewCheckInReaction) async throws -> CheckInReaction {
        return try await client
            .database
            .from(tableName)
            .insert(values: newCheckInReaction, returning: .representation)
            .select(columns: joinedWithProfile)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CheckInReaction.self)
    }
    
    func delete(id: Int) async throws {
        try await client
            .database
            .from(tableName)
            .delete().eq(column: "id", value: id)
            .execute()
    }
}
