import SwiftUI

struct IsPresentedInSheetKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isPresentedInSheet: Bool {
        get { self[IsPresentedInSheetKey.self] }
        set { self[IsPresentedInSheetKey.self] = newValue }
    }
}
