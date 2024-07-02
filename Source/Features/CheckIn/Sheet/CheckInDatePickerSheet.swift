import Components
import SwiftUI

struct CheckInDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var checkInAt: Date
    @Binding var isLegacyCheckIn: Bool
    @Binding var isNostalgic: Bool

    var body: some View {
        Form {
            Group {
                DatePicker("checkIn.datePicker.label", selection: $checkInAt, in: ...Date.now)
                    .datePickerStyle(.graphical)
                    .disabled(isLegacyCheckIn)
                Toggle("checkIn.datePicker.markAsLegacy.label", isOn: $isLegacyCheckIn)
                Toggle("checkIn.datePicker.markAsNostalgic.label", isOn: $isNostalgic)
            }
            .customListRowBackground()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("checkIn.datePicker.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
