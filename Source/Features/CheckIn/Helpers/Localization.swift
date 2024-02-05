import Models
import SwiftUI

public extension CheckInSegment {
    var label: LocalizedStringKey {
        switch self {
        case .everyone: "checkIn.segment.everyone"
        case .friends: "checkIn.segment.friends"
        case .you: "checkIn.segment.you"
        }
    }
}
