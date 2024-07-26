import Models
import SwiftUI

public struct ServingStyleLabelView: View {
    let servingStyle: ServingStyle.Saved

    public var body: some View {
        HStack {
            Text(servingStyle.label)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color(.systemGray))
                .clipShape(.capsule)
        }
    }
}

#Preview {
    ServingStyleLabelView(servingStyle: ServingStyle.Saved(id: 0, name: "bottle"))
}
