import Models
internal import Supabase

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient

    func insert(id: CheckIn.Id) async throws -> CheckIn.Reaction.Saved {
        try await client
            .rpc(fn: .createCheckInReaction, params: ["p_check_in_id": id.rawValue])
            .select(CheckIn.Reaction.getQuery(.joinedProfile(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(id: CheckIn.Reaction.Id) async throws {
        try await client
            .rpc(fn: .softDeleteCheckInReaction, params: ["p_check_in_reaction_id": id.rawValue])
            .execute()
    }
}
