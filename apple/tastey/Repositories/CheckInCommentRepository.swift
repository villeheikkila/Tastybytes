import Supabase

protocol CheckInCommentRepository {
    func insert(newCheckInComment: NewCheckInComment) async throws -> CheckInComment
    func update(updateCheckInComment: UpdateCheckInComment) async throws -> CheckInComment
    func getByCheckInId(id: Int) async throws -> [CheckInComment]
    func deleteById(id: Int) async throws -> Void
}

struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient
    private let tableName = "check_in_comments"
    private let joinedWithProfile = "id, content, created_at, profiles (id, username, avatar_url, name_display))"

    func insert(newCheckInComment: NewCheckInComment) async throws -> CheckInComment {
        return try await client
            .database
            .from(tableName)
            .insert(values: newCheckInComment, returning: .representation)
            .select(columns: joinedWithProfile)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CheckInComment.self)
    }

    func update(updateCheckInComment: UpdateCheckInComment) async throws -> CheckInComment {
        return try await client
            .database
            .from(tableName)
            .update(values: updateCheckInComment, returning: .representation)
            .eq(column: "id", value: updateCheckInComment.id)
            .select(columns: joinedWithProfile)
            .single()
            .execute()
            .decoded(to: CheckInComment.self)
    }

    func getByCheckInId(id: Int) async throws -> [CheckInComment] {
        return try await client
            .database
            .from(tableName)
            .select(columns: joinedWithProfile)
            .eq(column: "check_in_id", value: id)
            .order(column: "created_at")
            .execute()
            .decoded(to: [CheckInComment].self)
    }

    func deleteById(id: Int) async throws {
        try await client
            .database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
}
