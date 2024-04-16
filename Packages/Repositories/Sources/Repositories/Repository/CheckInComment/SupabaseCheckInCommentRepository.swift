import Models
import Supabase

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient

    func insert(newCheckInComment: CheckInComment.NewRequest) async -> Result<CheckInComment, Error> {
        do {
            let result: CheckInComment = try await client
                .from(.checkInComments)
                .insert(newCheckInComment, returning: .representation)
                .select(CheckInComment.getQuery(.joinedProfile(false)))
                .limit(1)
                .single()
                .execute()
                .value

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func update(updateCheckInComment: CheckInComment.UpdateRequest) async -> Result<CheckInComment, Error> {
        do {
            let response: CheckInComment = try await client
                .from(.checkInComments)
                .update(updateCheckInComment, returning: .representation)
                .eq("id", value: updateCheckInComment.id)
                .select(CheckInComment.getQuery(.joinedProfile(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error> {
        do {
            let response: [CheckInComment] = try await client
                .from(.checkInComments)
                .select(CheckInComment.getQuery(.joinedProfile(false)))
                .eq("check_in_id", value: id)
                .order("created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func deleteById(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .from(.checkInComments)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func deleteAsModerator(comment: CheckInComment) async -> Result<Void, Error> {
        do {
            try await client
                .rpc(
                    fn: .deleteCheckInCommentAsModerator,
                    params: CheckInComment.DeleteAsAdminRequest(comment: comment)
                )
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
