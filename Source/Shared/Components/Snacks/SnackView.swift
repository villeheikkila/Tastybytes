import Components
import SwiftUI

struct SnackView: View {
    @Environment(SnackController.self) private var snackController
    let id: UUID
    let tint: Color
    let systemName: String
    let message: LocalizedStringKey
    let onRetry: (() async -> Void)?

    init(
        id: UUID,
        tint: Color,
        systemName: String,
        message: LocalizedStringKey,
        onRetry: (() -> Void)? = nil
    ) {
        self.id = id
        self.tint = tint
        self.systemName = systemName
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        SnackContentView(
            tint: tint,
            systemName: systemName,
            message: message,
            onRetry: onRetry,
            onClose: {
                snackController.remove(id)
            }
        )
    }
}

struct SnackContentView: View {
    @State private var task: Task<Void, Never>?
    @State private var isLoading = false
    let tint: Color
    let systemName: String
    let message: LocalizedStringKey
    let onRetry: (() async -> Void)?
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(tint)

            Text(message)
                .font(.callout)

            Spacer(minLength: 0)

            if let onRetry {
                Button(action: {
                    guard task == nil else { return }
                    isLoading = true
                    task = Task {
                        await onRetry()
                        isLoading = false
                        task = nil
                    }
                }) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .rotationEffect(.degrees(90))
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(
                            isLoading ?
                                .linear(duration: 1)
                                .repeatForever(autoreverses: false) :
                                .default,
                            value: isLoading
                        )
                }
                .disabled(isLoading)
            }

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
        }
        .foregroundStyle(.primary)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .appleShadow()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview without retry button
        SnackContentView(
            tint: .red,
            systemName: "heart",
            message: "Error",
            onRetry: nil
        ) {}

        // Preview with retry button
        SnackContentView(
            tint: .red,
            systemName: "heart",
            message: "Error",
            onRetry: { try? await Task.sleep(for: .seconds(3)) }
        ) {}
    }
}
