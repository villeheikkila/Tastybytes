import Models

public protocol CheckInCommentRepository: Sendable {
    func insert(newCheckInComment: CheckInComment.NewRequest) async -> Result<CheckInComment, Error>
    func update(updateCheckInComment: CheckInComment.UpdateRequest) async -> Result<CheckInComment, Error>
    func getByCheckInId(id: Int) async -> Result<[CheckInComment], Error>
    func deleteById(id: Int) async -> Result<Void, Error>
    func deleteAsModerator(comment: CheckInComment) async -> Result<Void, Error>
}
