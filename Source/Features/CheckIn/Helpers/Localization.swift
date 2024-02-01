import Models
import SwiftUI

extension CheckInSegment {
    public var label: LocalizedStringKey {
        switch self {
        case .everyone: "check-in.segment.everyone"
        case .friends: "check-in.segment.friends"
        case .you: "check-in.segment.you"
        }
    }
}
