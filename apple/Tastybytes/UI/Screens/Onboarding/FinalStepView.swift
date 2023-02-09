import SwiftUI

struct FinalStepView: View {
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Text("Welcome to the \(Config.appName)")
          .font(.title3)
          .foregroundColor(.primary)

        Text("Some text here")
          .font(.body)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()

      HStack {
        Spacer()
        Button(action: {}) {
          Text("Continue to the app")
            .fontWeight(.medium)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        Spacer()
      }.padding(.bottom, 80)
    }
  }
}

struct FinalStepView_Previews: PreviewProvider {
  static var previews: some View {
    FinalStepView()
  }
}
