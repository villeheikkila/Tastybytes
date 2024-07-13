import Components
import SwiftUI

struct DeleteButtonView: View {
    let action: () async -> Void

    var body: some View {
        ProgressButton("labels.delete", systemImage: "trash.fill", role: .destructive, action: action)
    }
}

#Preview {
    DeleteButtonView(action: {})
}
