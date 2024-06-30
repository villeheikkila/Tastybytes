import EnvironmentModels
import OSLog
import SwiftUI

struct PhaseObserver<Content: View>: View {
    private let logger = Logger(category: "PhaseObserver")
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.scenePhase) private var phase

    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
        #if !os(watchOS)
            .onChange(of: phase) { _, newPhase in
                switch newPhase {
                case .active:
                    logger.info("Scene phase is active.")
                    Task {
                        guard let quickAction = await quickActionActor.selectedQuickAction else { return }
                        await UIApplication.shared.open(quickAction.getUrl(baseUrl: appEnvironmentModel.infoPlist.deepLinkBaseUrl))
                        await quickActionActor.setSelectedQuickAction(nil)
                    }
                case .inactive:
                    logger.info("Scene phase is inactive.")
                case .background:
                    logger.info("Scene phase is background.")
                    UIApplication.shared.shortcutItems = QuickAction.allCases.map(\.shortcutItem)
                @unknown default:
                    logger.info("Scene phase is unknown.")
                }
            }
        #endif
    }
}
