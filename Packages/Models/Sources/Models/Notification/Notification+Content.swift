public extension Notification {
    enum Content: Hashable, Sendable {
        case message(String)
        case friendRequest(Friend.Saved)
        case taggedCheckIn(CheckIn.Joined)
        case checkInReaction(CheckIn.Reaction.JoinedCheckIn)
        case checkInComment(CheckIn.Comment.Joined)
    }
}
