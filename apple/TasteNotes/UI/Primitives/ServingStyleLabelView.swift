import SwiftUI

struct ServingStyleLabelView: View {
    let servingStyle: ServingStyle
    var body: some View {
        HStack {
            Text(servingStyle.name.rawValue.capitalized)
                .font(.system(size: 12, weight: .bold, design: .default))
        }
    }
}

struct ServingStyleLabelView_Previews: PreviewProvider {
    static var previews: some View {
        ServingStyleLabelView(servingStyle: ServingStyle(id: 0, name: ServingStyleName.bottle))
    }
}
