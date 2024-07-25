import Models

public protocol CheckInReactionsRepository: Sendable {
    func insert(id: CheckIn.Id) async throws -> CheckIn.Reaction.Saved
    func delete(id: CheckIn.Reaction.Id) async throws
}
