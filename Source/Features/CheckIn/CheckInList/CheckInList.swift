import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListSegmentPicker: View {
    @Binding var showCheckInsFrom: CheckInSegment

    var body: some View {
        Picker("checkIn.segment.picker.title", selection: $showCheckInsFrom) {
            ForEach(CheckInSegment.allCases, id: \.self) { segment in
                Text(segment.label)
            }
        }
        .pickerStyle(.segmented)
        .listRowSeparator(.visible, edges: .bottom)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}

extension CheckInSegment {
    var emptyContentView: some View {
        switch self {
        case .everyone:
            ContentUnavailableView {
                Label("checkIn.segment.everyone.emptyContent.title", systemImage: "list.star")
            }
        case .friends:
            ContentUnavailableView {
                Label("checkIn.segment.friends.emptyContent.title", systemImage: "list.star")
            }
        case .you:
            ContentUnavailableView {
                Label("checkIn.segment.you.emptyContent.title", systemImage: "list.star")
            }
        }
    }
}
