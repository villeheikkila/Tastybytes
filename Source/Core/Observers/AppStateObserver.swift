
import SwiftUI

struct AppStateObserver<Content: View>: View {
    @Environment(AppModel.self) private var appModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch appModel.state {
        case .operational:
            content()
        case let .error(errors):
            AppErrorStateView(errors: errors)
        case .tooOldAppVersion:
            AppUnsupportedVersionState()
        case .underMaintenance:
            AppUnderMaintenanceState()
        case .loading:
            EmptyView()
        }
    }
}
