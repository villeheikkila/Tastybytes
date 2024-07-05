import Components
import SwiftUI

struct ConfirmedDeleteButtonView<Presenting>: View {
    @State private var showDeleteConfirmation = false
    let presenting: Presenting
    let action: @MainActor (Presenting) async -> Void
    let description: LocalizedStringKey
    let label: LocalizedStringKey

    let isDisabled: Bool

    var body: some View {
        Section {
            Button(
                "labels.delete",
                systemImage: "trash.fill",
                role: .destructive,
                action: { showDeleteConfirmation = true }
            )
            .foregroundColor(.red)
            .disabled(isDisabled)
        }
        .confirmationDialog(
            description,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            presenting: presenting
        ) { presenting in
            ProgressButton(
                label,
                role: .destructive,
                action: {
                    await action(presenting)
                }
            )
        }
    }
}
