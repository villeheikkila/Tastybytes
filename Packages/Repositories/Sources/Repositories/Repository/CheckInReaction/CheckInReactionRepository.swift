import Models

public protocol CheckInReactionsRepository {
    func insert(newCheckInReaction: CheckInReaction.NewRequest) async -> Result<CheckInReaction, Error>
    func delete(id: Int) async -> Result<Void, Error>
}
