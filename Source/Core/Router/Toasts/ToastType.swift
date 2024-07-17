import EnvironmentModels
import SwiftUI

enum ToastType {
    case success(_ title: LocalizedStringKey? = nil)
    case warning(_ title: LocalizedStringKey? = nil)
    case error(_ title: LocalizedStringKey? = nil)

    var toastEvent: ToastEvent {
        switch self {
        case let .success(title):
            .init(type: .complete(.green), title: title)
        case let .warning(title):
            .init(type: .systemImage("exclamationmark.triangle", .yellow), title: title)
        case let .error(title):
            .init(type: .error(.red), title: title)
        }
    }
}
