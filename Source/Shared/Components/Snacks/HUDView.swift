import SwiftUI

struct HUDView: View {
    let systemName: String
    let foregroundColor: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(foregroundColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .appleShadow()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    HUDView(systemName: "heart", foregroundColor: .red, title: "Interesting", subtitle: "This is a very interesting thing")
}