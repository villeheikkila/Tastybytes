import Components
import SwiftUI

@MainActor
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
                    Text("deleteAccount.success.title")
                        .font(.title)

                    VStack(spacing: 8) {
                        Text("settings.account.delete.disclaimer")
                        Text("deleteAccount.success.welcomeBack")
                    }
                    .multilineTextAlignment(.center)

                    ProgressButton(
                        action: {
                            exit(0)
                        },
                        label: {
                            Text("deleteAccount.success.done.label")
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
