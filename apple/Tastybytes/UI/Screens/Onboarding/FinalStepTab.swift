import SwiftUI

struct FinalStepTab: View {
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
        ProgressButton(
          "Continue to the app",
          action: { await viewModel.updateProfile { await profileManager.refresh() } }
        )
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        Spacer()
      }.padding(.bottom, 80)
    }
  }
}
