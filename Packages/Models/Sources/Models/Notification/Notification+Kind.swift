public extension Notification {
    enum Kind: String, CaseIterable, Identifiable, Sendable {
        public var id: Self {
            self
        }
        
        case message, friendRequest, taggedCheckIn, checkInReaction, checkInComment
    }
}
