public extension Notification {
     enum Content: Hashable, Sendable {
        case message(String)
        case friendRequest(Friend.Saved)
        case taggedCheckIn(CheckIn)
        case checkInReaction(CheckInReaction.JoinedCheckIn)
        case checkInComment(CheckInComment.Joined)
    }
}
