import SwiftUI

@MainActor
@Observable
final class TabManager {
    var selection = Tab.activity {
        didSet {
            if oldValue == selection {
                scrollToTop()
            }
        }
    }

    var resetNavigationOnTab: Tab? = nil

    private func scrollToTop() {
        resetNavigationOnTab = nil
        Task {
            try? await Task.sleep(for: .milliseconds(1))
            resetNavigationOnTab = selection
        }
    }
}
