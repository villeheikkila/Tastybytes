import SwiftUI

struct ChipView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title).font(.caption2).bold()
        }
        .padding(2)
        .foregroundColor(.white)
        .background(Color(.systemBlue))
        .cornerRadius(5)
    }
}
