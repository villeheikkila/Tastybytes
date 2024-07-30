import Models
internal import Supabase

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient

    func insert(newCheckInComment: CheckIn.Comment.NewRequest) async throws -> CheckIn.Comment.Saved {
        try await client
            .from(.checkInComments)
            .insert(newCheckInComment, returning: .representation)
            .select(CheckIn.Comment.getQuery(.joinedProfile(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func update(updateCheckInComment: CheckIn.Comment.UpdateRequest) async throws -> CheckIn.Comment.Saved {
        try await client
            .from(.checkInComments)
            .update(updateCheckInComment, returning: .representation)
            .eq("id", value: updateCheckInComment.id.rawValue)
            .select(CheckIn.Comment.getQuery(.joinedProfile(false)))
            .single()
            .execute()
            .value
    }

    func getByCheckInId(id: CheckIn.Id) async throws -> [CheckIn.Comment.Saved] {
        try await client
            .from(.checkInComments)
            .select(CheckIn.Comment.getQuery(.joinedProfile(false)))
            .eq("check_in_id", value: id.rawValue)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func deleteById(id: CheckIn.Comment.Id) async throws {
        try await client
            .from(.checkInComments)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func getDetailed(id: CheckIn.Comment.Id) async throws -> CheckIn.Comment.Detailed {
        try await client
            .from(.checkInComments)
            .select(CheckIn.Comment.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func deleteAsModerator(id: CheckIn.Comment.Id) async throws {
        try await client
            .rpc(
                fn: .deleteCheckInCommentAsModerator,
                params: ["p_check_in_comment_id": id.rawValue]
            )
            .execute()
    }
}
