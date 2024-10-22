
import Extensions
import Models
import Logging
import Repositories
import SwiftUI

@MainActor
@Observable
final class Router {
    enum Open {
        case sheet(Sheet)
        case screen(Screen, resetStack: Bool = false, removeLast: Bool = false)
        case alert(AlertEvent)
        case fullScreenCover(FullScreenCover)
        case toast(ToastType)
    }

    var path = [Screen]()
    var sheet: Sheet?
    var alert: AlertEvent?
    var fullScreenCover: FullScreenCover?
    var toast: ToastType?

    init(path: [Screen] = [], sheet: Sheet? = nil) {
        self.path = path
        self.sheet = sheet
    }

    func open(_ open: Open) {
        switch open {
        case let .screen(screen, resetStack: resetStack, removeLast: removeLast):
            if resetStack {
                reset()
            }
            path.append(screen)
            if removeLast {
                guard path.count >= 2 else { return }
                path.remove(at: path.count - 2)
            }
        case let .sheet(sheet):
            self.sheet = sheet
        case let .alert(alert):
            self.alert = alert
        case let .fullScreenCover(fullScreenCover):
            self.fullScreenCover = fullScreenCover
        case let .toast(toast):
            self.toast = toast
        }
    }

    func reset() {
        path = []
    }

    func removeLast() {
        path.removeLast()
    }
}
