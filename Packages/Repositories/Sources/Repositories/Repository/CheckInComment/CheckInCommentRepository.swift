import Models

public protocol CheckInCommentRepository: Sendable {
    func insert(newCheckInComment: CheckInComment.NewRequest) async throws -> CheckInComment
    func update(updateCheckInComment: CheckInComment.UpdateRequest) async throws -> CheckInComment
    func getByCheckInId(id: CheckIn.Id) async throws -> [CheckInComment]
    func deleteById(id: CheckInComment.Id) async throws
    func deleteAsModerator(comment: CheckInComment) async throws
}
