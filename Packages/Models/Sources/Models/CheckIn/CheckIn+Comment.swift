import Foundation
public import Tagged

public extension CheckIn {
    enum Comment {}
}

public extension CheckIn.Comment {
    typealias Id = Tagged<CheckIn.Comment, Int>
}

public protocol CheckInCommentProtocol {
    var id: CheckIn.Comment.Id { get }
    var content: String { get }
    var createdAt: Date { get }
    var profile: Profile.Saved { get }
}
