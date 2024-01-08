import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct AppConfigProvider<Content: View>: View {
    private let logger = Logger(category: "AppConfigProvider")
    @State private var appConfigEnvironmentModel: AppConfigEnvironmentModel

    @ViewBuilder let content: () -> Content

    init(repository: Repository, @ViewBuilder content: @escaping () -> Content) {
        _appConfigEnvironmentModel = State(wrappedValue: AppConfigEnvironmentModel(repository: repository))
        self.content = content
    }

    var body: some View {
        VStack {
            if appConfigEnvironmentModel.appConfig != nil {
                content().environment(appConfigEnvironmentModel)
            }
        }.task {
            await appConfigEnvironmentModel.initialize()
        }
    }
}
