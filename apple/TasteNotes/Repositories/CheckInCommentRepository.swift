import Supabase

protocol CheckInCommentRepository {
    func insert(newCheckInComment: NewCheckInComment) async -> Result<CheckInComment, Error>
    func update(updateCheckInComment: UpdateCheckInComment) async -> Result<CheckInComment, Error>
    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error>
    func deleteById(id: Int) async -> Result<Void, Error>
}

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient
    private let tableName = CheckInComment.getQuery(.tableName)
    private let joinedWithProfile = CheckInComment.getQuery(.joinedProfile(false))

    func insert(newCheckInComment: NewCheckInComment) async -> Result<CheckInComment, Error> {
        do {
            let result = try await client
                .database
                .from(tableName)
                .insert(values: newCheckInComment, returning: .representation)
                .select(columns: joinedWithProfile)
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
                .from(tableName)
                .update(values: updateCheckInComment, returning: .representation)
                .eq(column: "id", value: updateCheckInComment.id)
                .select(columns: joinedWithProfile)
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
                .from(tableName)
                .select(columns: joinedWithProfile)
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
                .from(tableName)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
