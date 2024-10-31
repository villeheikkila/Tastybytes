import SwiftUI

struct SnackView: View {
    @Environment(SnackController.self) private var snackController
    let id: UUID
    let tint: Color
    let systemName: String
    let message: LocalizedStringKey

    var body: some View {
        SnackContentView(tint: tint, systemName: systemName, message: message, onClose: {
            snackController.remove(id)
        })
    }
}

struct SnackContentView: View {
    let tint: Color
    let systemName: String
    let message: LocalizedStringKey
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
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.primary, .ultraThinMaterial)
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
    SnackContentView(
        tint: .red,
        systemName: "heart",
        message: "Error"
    ) {}
}
