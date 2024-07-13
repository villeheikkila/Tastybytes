import Models
internal import Supabase

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient

    func insert(newCheckInReaction: CheckInReaction.NewRequest) async throws -> CheckInReaction {
        try await client
            .rpc(fn: .createCheckInReaction, params: newCheckInReaction)
            .select(CheckInReaction.getQuery(.joinedProfile(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .rpc(fn: .softDeleteCheckInReaction, params: CheckInReaction.DeleteRequest(id: id))
            .execute()
    }
}
