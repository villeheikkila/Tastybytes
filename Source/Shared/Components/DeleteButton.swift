import Components
import SwiftUI

struct DeleteButton: View {
    let action: () async -> Void

    var body: some View {
        ProgressButton("labels.delete", systemImage: "trash.fill", role: .destructive, action: action)
    }
}

#Preview {
    DeleteButton(action: {})
}
