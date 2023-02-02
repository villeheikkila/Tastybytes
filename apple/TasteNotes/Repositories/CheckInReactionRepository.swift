import Foundation
import Supabase

protocol CheckInReactionsRepository {
  func insert(newCheckInReaction: CheckInReaction.NewRequest) async -> Result<CheckInReaction, Error>
  func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseCheckInReactionsRepository: CheckInReactionsRepository {
  let client: SupabaseClient

  func insert(newCheckInReaction: CheckInReaction.NewRequest) async -> Result<CheckInReaction, Error> {
    do {
      let response: CheckInReaction = try await client
        .database
        .rpc(fn: "fnc__create_check_in_reaction", params: newCheckInReaction)
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

  func delete(id: Int) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__soft_delete_check_in_reaction", params: CheckInReaction.DeleteRequest(id: id))
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }
}
