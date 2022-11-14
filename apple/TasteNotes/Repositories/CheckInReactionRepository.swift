import Foundation
import Supabase

protocol CheckInReactionsRepository {
    func insert(newCheckInReaction: NewCheckInReaction) async throws -> CheckInReaction
    func delete(id: Int) async throws -> Void
}

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient
    
    func insert(newCheckInReaction: NewCheckInReaction) async throws -> CheckInReaction {
        return try await client
            .database
            .from(CheckInReaction.getQuery(.tableName))
            .insert(values: newCheckInReaction, returning: .representation)
            .select(columns: CheckInReaction.getQuery(.joinedProfile(false)))
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CheckInReaction.self)
    }
    
    func delete(id: Int) async throws {
        try await client
            .database
            .from(CheckInReaction.getQuery(.tableName))
            .delete().eq(column: "id", value: id)
            .execute()
    }
}
