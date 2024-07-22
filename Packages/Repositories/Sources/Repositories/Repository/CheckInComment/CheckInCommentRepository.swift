import Models

public protocol CheckInCommentRepository: Sendable {
    func insert(newCheckInComment: CheckInComment.NewRequest) async throws -> CheckInComment
    func update(updateCheckInComment: CheckInComment.UpdateRequest) async throws -> CheckInComment
    func getByCheckInId(id: CheckIn.Id) async throws -> [CheckInComment]
    func getDetailed(id: CheckInComment.Id) async throws -> CheckInComment.Detailed
    func deleteById(id: CheckInComment.Id) async throws
    func deleteAsModerator(id: CheckInComment.Id) async throws
}
