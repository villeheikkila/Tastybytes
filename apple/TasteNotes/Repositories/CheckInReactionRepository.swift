import Foundation
import Supabase

protocol CheckInReactionsRepository {
    func insert(newCheckInReaction: NewCheckInReaction) async -> Result<CheckInReaction, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient
    
    func insert(newCheckInReaction: NewCheckInReaction) async -> Result<CheckInReaction, Error> {
        do {
            let response = try await client
                .database
                .from(CheckInReaction.getQuery(.tableName))
                .insert(values: newCheckInReaction, returning: .representation)
                .select(columns: CheckInReaction.getQuery(.joinedProfile(false)))
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CheckInReaction.self)
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func delete(id: Int) async -> Result<Void, Error> {
        do {
             try await client
                .database
                .from(CheckInReaction.getQuery(.tableName))
                .delete().eq(column: "id", value: id)
                .execute()
            
            return .success(Void()) }
        catch {
            return .failure(error)
        }
    }
}
