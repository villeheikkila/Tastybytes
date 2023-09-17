import Models
import Supabase

public protocol CheckInReactionsRepository {
    func insert(newCheckInReaction: CheckInReaction.NewRequest) async -> Result<CheckInReaction, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

public struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
    let client: SupabaseClient

    public func insert(newCheckInReaction: CheckInReaction.NewRequest) async -> Result<CheckInReaction, Error> {
        do {
            let response: CheckInReaction = try await client
                .database
                .rpc(fn: .createCheckInReaction, params: newCheckInReaction)
                .select(columns: CheckInReaction.getQuery(.joinedProfile(false)))
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .softDeleteCheckInReaction, params: CheckInReaction.DeleteRequest(id: id))
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

public extension CheckInReaction {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInReactions.rawValue
        let saved = "id"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfileCheckIn(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
    }
}
