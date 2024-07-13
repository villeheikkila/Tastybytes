import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthenticationScreen: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        VStack(alignment: .center) {
            #if !os(watchOS)
                RouterProvider(enableRoutingFromURLs: false) {
                    AuthenticationScreenContentView()
                }
            #else
                AuthenticationScreenWatchOSContent()
            #endif
        }
        .background(
            AppGradientView(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1)),
            alignment: .bottom
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
