import Models
import SwiftUI

public struct ServingStyleLabelView: View {
    let servingStyle: ServingStyle

    public var body: some View {
        HStack {
            Text(servingStyle.label)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(.white)
            #if !os(watchOS)
                .background(Color(.systemGray))
            #endif
                .clipShape(.capsule)
        }
    }
}

#Preview {
    ServingStyleLabelView(servingStyle: ServingStyle(id: 0, name: "bottle"))
}
