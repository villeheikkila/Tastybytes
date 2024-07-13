import Models

public protocol CheckInReactionsRepository: Sendable {
    func insert(newCheckInReaction: CheckInReaction.NewRequest) async throws -> CheckInReaction
    func delete(id: Int) async throws
}
