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
        onRetry: (() async -> Void)?
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
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(tint)
            Text(message)
                .font(.callout)
            Spacer(minLength: 0)
            Group {
                if onRetry != nil {
                    retryButton
                } else {
                    Button("labels.close", systemImage: "xmark") {
                        onClose()
                    }
                    .font(.callout)
                    .foregroundStyle(.primary)
                }
            }
            .labelStyle(.iconOnly)
        }
        .foregroundStyle(.primary)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .appleShadow()
        }
        .contextMenu {
            retryButton
            Button("labels.close", systemImage: "xmark") {
                onClose()
            }
            .font(.callout)
            .foregroundStyle(.primary)
        }
    }

    @ViewBuilder private
    var retryButton: some View {
        if let onRetry {
            Button("labels.retry", systemImage: "arrow.trianglehead.2.clockwise") {
                guard task == nil else { return }
                isLoading = true
                task = Task {
                    await onRetry()
                    isLoading = false
                    task = nil
                }
            }
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
            .disabled(isLoading)
        }
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
