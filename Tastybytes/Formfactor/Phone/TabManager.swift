import SwiftUI

@Observable
final class TabManager {
    var selection: Tab {
        get {
            access(keyPath: \.selection)
            let value: Tab? = UserDefaults.standard.codable(forKey: .selectedTab)
            return value ?? .activity
        }
        set {
            withMutation(keyPath: \.selection) {
                if newValue == selection {
                    scrollToTop()
                } else {
                    UserDefaults.standard.set(value: newValue, forKey: .selectedTab)
                }
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
