import SwiftUI

struct ServingStyleLabelView: View {
  let servingStyle: ServingStyle

  var body: some View {
    HStack {
      Text(servingStyle.label)
        .font(.caption).bold()
    }
  }
}

struct ServingStyleLabelView_Previews: PreviewProvider {
  static var previews: some View {
    ServingStyleLabelView(servingStyle: ServingStyle(id: 0, name: "bottle"))
  }
}
