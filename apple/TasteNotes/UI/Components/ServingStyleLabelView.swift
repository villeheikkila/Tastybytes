import SwiftUI

struct ServingStyleLabelView: View {
  let servingStyleName: ServingStyleName

  var body: some View {
    HStack {
      Text(servingStyleName.rawValue.capitalized)
        .font(.system(size: 12, weight: .bold, design: .default))
    }
  }
}

struct ServingStyleLabelView_Previews: PreviewProvider {
  static var previews: some View {
    ServingStyleLabelView(servingStyleName: ServingStyleName.bottle)
  }
}
