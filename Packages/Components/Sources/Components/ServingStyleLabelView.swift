import Models
import SwiftUI

@MainActor
public struct ServingStyleLabelView: View {
    let servingStyle: ServingStyle

    public var body: some View {
        HStack {
            Text(servingStyle.label)
                .font(.caption)
                .fontWeight(.bold)
                .padding(4)
                .foregroundColor(.white)
            #if !os(watchOS)
                .background(Color(.systemGray))
            #endif
                .cornerRadius(6)
        }
    }
}

#Preview {
    ServingStyleLabelView(servingStyle: ServingStyle(id: 0, name: "bottle"))
}
