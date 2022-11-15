import SwiftUI

class RouteManager: ObservableObject {
    @Published var path = NavigationPath()

    func gotoHomePage() {
        path = NavigationPath()
    }

    func removeLast() {
        path.removeLast()
    }

    func tapOnSecondPage() {
        path.removeLast()
    }

    func navigateTo(destination: some Hashable, resetStack: Bool) {
        if resetStack {
            path.removeLast(path.count)
        }
        path.append(destination)
    }
}
