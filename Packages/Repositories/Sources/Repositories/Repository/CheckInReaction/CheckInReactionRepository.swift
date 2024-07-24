import Models

public protocol CheckInReactionsRepository: Sendable {
    func insert(newCheckInReaction: CheckIn.Reaction.NewRequest) async throws -> CheckIn.Reaction.Saved
    func delete(id: CheckIn.Reaction.Id) async throws
}
