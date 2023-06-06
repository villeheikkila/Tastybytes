import SwiftUI

struct AccountDeletedScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        VStack(spacing: 18) {
          Image(systemSymbol: .trashCircle)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(.red)
            .accessibility(hidden: true)
          Text("Account Deleted")
            .font(.title)

          VStack(spacing: 8) {
            Text("All your personal information has been permanently deleted from the system.")
            Text("Sorry to see you go but you're always welcome back!")
          }
          .multilineTextAlignment(.center)

          ProgressButton(action: {
            exit(0)
          }) {
            Text("Quit the App")
              .font(.headline)
              .padding(.all, 8)
          }
          .buttonStyle(.borderedProminent)
        }
        .padding([.leading, .trailing], 24)
        Spacer()
      }
      Spacer()
    }
  }
}

#Preview {
    AccountDeletedScreen()
  }
