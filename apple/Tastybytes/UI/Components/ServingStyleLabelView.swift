import SwiftUI

struct ServingStyleLabelView: View {
  let servingStyleName: ServingStyle.Name

  var body: some View {
    HStack {
      Text(servingStyleName.rawValue.capitalized)
        .font(.caption).bold()
    }
  }
}

struct ServingStyleLabelView_Previews: PreviewProvider {
  static var previews: some View {
    ServingStyleLabelView(servingStyleName: ServingStyle.Name.bottle)
  }
}
