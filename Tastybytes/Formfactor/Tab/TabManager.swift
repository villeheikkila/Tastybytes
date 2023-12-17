import SwiftUI

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.resetNavigationOnTab = self.selection
        }
    }
}
