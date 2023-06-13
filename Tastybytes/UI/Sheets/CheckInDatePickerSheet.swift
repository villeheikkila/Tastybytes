import SwiftUI

struct CheckInDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var checkInAt: Date
    @Binding var isLegacyCheckIn: Bool

    var body: some View {
        Form {
            DatePicker("Check-in date", selection: $checkInAt, in: ...Date.now)
                .datePickerStyle(.graphical)
                .disabled(isLegacyCheckIn)
            Toggle("Mark as legacy check-in", isOn: $isLegacyCheckIn)
        }
        .navigationTitle("Check-in Date")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }
}