import Models
import SwiftUI

public struct ServingStyleLabelView: View {
    let servingStyle: ServingStyle

    public var body: some View {
        HStack {
            Text(servingStyle.label)
                .font(.caption)
                .fontWeight(.bold)
                .padding(4)
                .foregroundColor(.white)
                .background(Color(.systemGray))
                .cornerRadius(6)
        }
    }
}

#Preview {
    ServingStyleLabelView(servingStyle: ServingStyle(id: 0, name: "bottle"))
}
