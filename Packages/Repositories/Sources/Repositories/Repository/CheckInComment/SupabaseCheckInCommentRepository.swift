import Models
internal import Supabase

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient

    func insert(newCheckInComment: CheckInComment.NewRequest) async throws -> CheckInComment {
        try await client
            .from(.checkInComments)
            .insert(newCheckInComment, returning: .representation)
            .select(CheckInComment.getQuery(.joinedProfile(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func update(updateCheckInComment: CheckInComment.UpdateRequest) async throws -> CheckInComment {
        try await client
            .from(.checkInComments)
            .update(updateCheckInComment, returning: .representation)
            .eq("id", value: updateCheckInComment.id)
            .select(CheckInComment.getQuery(.joinedProfile(false)))
            .single()
            .execute()
            .value
    }

    func getByCheckInId(id: Int) async throws -> [CheckInComment] {
        try await client
            .from(.checkInComments)
            .select(CheckInComment.getQuery(.joinedProfile(false)))
            .eq("check_in_id", value: id)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func deleteById(id: Int) async throws {
        try await client
            .from(.checkInComments)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func deleteAsModerator(comment: CheckInComment) async throws {
        try await client
            .rpc(
                fn: .deleteCheckInCommentAsModerator,
                params: CheckInComment.DeleteAsAdminRequest(comment: comment)
            )
            .execute()
    }
}
