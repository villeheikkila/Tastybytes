import EnvironmentModels
import SwiftUI

enum ToastType {
    case success(_ title: LocalizedStringKey)
    case warning(_ title: LocalizedStringKey)

    var toastEvent: ToastEvent {
        switch self {
        case let .success(title):
            .init(type: .complete(.green), title: title)
        case let .warning(title):
            .init(type: .error(.red), title: title)
        }
    }
}
