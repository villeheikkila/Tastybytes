import SwiftUI

struct VerificationAdminToggleView: View {
    @State private var task: Task<Void, Never>?
    let isVerified: Bool

    let action: (_ isVerified: Bool) async -> Void

    var body: some View {
        Toggle("verification.verified.label", isOn: toggleBinding())
            .disabled(task != nil)
    }

    private func toggleBinding() -> Binding<Bool> {
        Binding(
            get: { isVerified },
            set: { newValue in
                guard task == nil else { return }
                task = Task {
                    defer { task = nil }
                    await action(newValue)
                }
            }
        )
    }
}
