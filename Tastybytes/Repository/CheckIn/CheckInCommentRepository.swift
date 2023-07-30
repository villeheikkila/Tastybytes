import Supabase

protocol CheckInCommentRepository {
    func insert(newCheckInComment: CheckInComment.NewRequest) async -> Result<CheckInComment, Error>
    func update(updateCheckInComment: CheckInComment.UpdateRequest) async -> Result<CheckInComment, Error>
    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error>
    func deleteById(id: Int) async -> Result<Void, Error>
    func deleteAsModerator(comment: CheckInComment) async -> Result<Void, Error>
}

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient

    func insert(newCheckInComment: CheckInComment.NewRequest) async -> Result<CheckInComment, Error> {
        do {
            let result: CheckInComment = try await client
                .database
                .from(.checkInComments)
                .insert(values: newCheckInComment, returning: .representation)
                .select(columns: CheckInComment.getQuery(.joinedProfile(false)))
                .limit(count: 1)
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
                .database
                .from(.checkInComments)
                .update(values: updateCheckInComment, returning: .representation)
                .eq(column: "id", value: updateCheckInComment.id)
                .select(columns: CheckInComment.getQuery(.joinedProfile(false)))
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
                .database
                .from(.checkInComments)
                .select(columns: CheckInComment.getQuery(.joinedProfile(false)))
                .eq(column: "check_in_id", value: id)
                .order(column: "created_at")
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
                .database
                .from(.checkInComments)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func deleteAsModerator(comment: CheckInComment) async -> Result<Void, Error> {
        do {
            try await client
                .database
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
