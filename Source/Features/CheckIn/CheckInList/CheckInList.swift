import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct CheckInListSegmentPickerView: View {
    @Binding var showCheckInsFrom: CheckIn.Segment

    var body: some View {
        Picker("checkIn.segment.picker.title", selection: $showCheckInsFrom) {
            ForEach(CheckIn.Segment.allCases, id: \.self) { segment in
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

extension CheckIn.Segment {
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
