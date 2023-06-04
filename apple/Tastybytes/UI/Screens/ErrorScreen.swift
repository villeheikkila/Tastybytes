import SwiftUI

struct ErrorScreen: View {
  let reason: String

  var body: some View {
    VStack {
      Image(systemSymbol: .exclamationmarkTriangle)
        .font(.system(size: 60))
        .foregroundColor(.red)
      Text("Oops!")
        .font(.title)
        .bold()
        .padding(.bottom, 2)
      Text(reason)
        .multilineTextAlignment(.center)
    }
    .padding()
  }
}

struct ErrorScreen_Previews: PreviewProvider {
  static var previews: some View {
    ErrorScreen(reason: "Page could not be found")
  }
}
