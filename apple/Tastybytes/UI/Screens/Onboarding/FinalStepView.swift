import SwiftUI

struct FinalStepView: View {
  @EnvironmentObject private var viewModel: OnboardingViewModel
  @EnvironmentObject private var profileManager: ProfileManager

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
        Button(action: { viewModel.updateProfile { profileManager.refresh() }}, label: {
          Text("Continue to the app")
            .fontWeight(.medium)
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        Spacer()
      }.padding(.bottom, 80)
    }
  }
}
