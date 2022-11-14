import Supabase

protocol CheckInCommentRepository {
    func insert(newCheckInComment: NewCheckInComment) async -> Result<CheckInComment, Error>
    func update(updateCheckInComment: UpdateCheckInComment) async -> Result<CheckInComment, Error>
    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error>
    func deleteById(id: Int) async -> Result<Void, Error>
}

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient

    func insert(newCheckInComment: NewCheckInComment) async -> Result<CheckInComment, Error> {
        do {
            let result = try await client
                .database
                .from(CheckInComment.getQuery(.tableName))
                .insert(values: newCheckInComment, returning: .representation)
                .select(columns: CheckInComment.getQuery(.joinedProfile(false)))
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CheckInComment.self)
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func update(updateCheckInComment: UpdateCheckInComment) async -> Result<CheckInComment, Error> {
        do {
            let response = try await client
                .database
                .from(CheckInComment.getQuery(.tableName))
                .update(values: updateCheckInComment, returning: .representation)
                .eq(column: "id", value: updateCheckInComment.id)
                .select(columns: CheckInComment.getQuery(.joinedProfile(false)))
                .single()
                .execute()
                .decoded(to: CheckInComment.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error> {
        do {
            let response = try await client
                .database
                .from(CheckInComment.getQuery(.tableName))
                .select(columns: CheckInComment.getQuery(.joinedProfile(false)))
                .eq(column: "check_in_id", value: id)
                .order(column: "created_at")
                .execute()
                .decoded(to: [CheckInComment].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func deleteById(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(CheckInComment.getQuery(.tableName))
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
