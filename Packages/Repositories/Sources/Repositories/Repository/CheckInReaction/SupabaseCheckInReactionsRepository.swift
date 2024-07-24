import Models
internal import Supabase

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient

    func insert(newCheckInReaction: CheckIn.Reaction.NewRequest) async throws -> CheckIn.Reaction.Saved {
        try await client
            .rpc(fn: .createCheckInReaction, params: newCheckInReaction)
            .select(CheckIn.Reaction.getQuery(.joinedProfile(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(id: CheckIn.Reaction.Id) async throws {
        try await client
            .rpc(fn: .softDeleteCheckInReaction, params: CheckIn.Reaction.DeleteRequest(id: id))
            .execute()
    }
}
