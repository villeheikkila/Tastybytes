import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthenticationScreenWatchOSContent: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    Spacer()
                    AppLogoView(appIcon: .ramune)
                        .frame(width: 50, height: 50)
                    Spacer()
                }
                AppNameView(size: 22)
            }
            Spacer()
            SignInWithAppleView()
                .frame(height: 28)
                .padding()
                .padding()
            Spacer()
        }
    }
}
