import Models

public protocol CheckInCommentRepository: Sendable {
    func insert(newCheckInComment: CheckInComment.NewRequest) async throws -> CheckInComment
    func update(updateCheckInComment: CheckInComment.UpdateRequest) async throws -> CheckInComment
    func getByCheckInId(id: Int) async throws -> [CheckInComment]
    func deleteById(id: Int) async throws
    func deleteAsModerator(comment: CheckInComment) async throws
}
