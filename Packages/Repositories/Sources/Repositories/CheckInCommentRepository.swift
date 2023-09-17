import Models
import Supabase

public protocol CheckInCommentRepository {
    func insert(newCheckInComment: CheckInComment.NewRequest) async -> Result<CheckInComment, Error>
    func update(updateCheckInComment: CheckInComment.UpdateRequest) async -> Result<CheckInComment, Error>
    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error>
    func deleteById(id: Int) async -> Result<Void, Error>
    func deleteAsModerator(comment: CheckInComment) async -> Result<Void, Error>
}

public struct SupabaseCheckInCommentRepository: CheckInCommentRepository {
    let client: SupabaseClient

    public func insert(newCheckInComment: CheckInComment.NewRequest) async -> Result<CheckInComment, Error> {
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

    public func update(updateCheckInComment: CheckInComment.UpdateRequest) async -> Result<CheckInComment, Error> {
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

    public func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error> {
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

    public func deleteById(id: Int) async -> Result<Void, Error> {
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

    public func deleteAsModerator(comment: CheckInComment) async -> Result<Void, Error> {
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

public extension CheckInComment {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInComments.rawValue
        let saved = "id, content, created_at"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
        case let .joinedCheckIn(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedCheckIn(_ withTableName: Bool)
    }
}
