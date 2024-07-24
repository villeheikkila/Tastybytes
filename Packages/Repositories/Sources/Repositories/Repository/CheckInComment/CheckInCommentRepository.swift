import Models

public protocol CheckInCommentRepository: Sendable {
    func insert(newCheckInComment: CheckIn.Comment.NewRequest) async throws -> CheckIn.Comment.Saved
    func update(updateCheckInComment: CheckIn.Comment.UpdateRequest) async throws -> CheckIn.Comment.Saved
    func getByCheckInId(id: CheckIn.Id) async throws -> [CheckIn.Comment.Saved]
    func getDetailed(id: CheckIn.Comment.Id) async throws -> CheckIn.Comment.Detailed
    func deleteById(id: CheckIn.Comment.Id) async throws
    func deleteAsModerator(id: CheckIn.Comment.Id) async throws
}
