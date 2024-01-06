import Components
import SwiftUI

struct AccountDeletedScreen: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 18) {
                    Image(systemName: "trash.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.red)
                        .accessibility(hidden: true)
                    Text("Account Deleted")
                        .font(.title)

                    VStack(spacing: 8) {
                        Text("settings.account.delete.disclaimer")
                        Text("Sorry to see you go but you're always welcome back!")
                    }
                    .multilineTextAlignment(.center)

                    ProgressButton(
                        action: {
                            exit(0)
                        },
                        label: {
                            Text("Quit the App")
                                .font(.headline)
                                .padding(.all, 8)
                        }
                    )
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 24)
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    AccountDeletedScreen()
}
