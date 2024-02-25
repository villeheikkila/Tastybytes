import SwiftUI

public extension Binding {
    func isNotNull<V>() -> Binding<Bool> where Value == V? {
        Binding<Bool>(get: { self.wrappedValue != nil },
                      set: { _ in self.wrappedValue = nil })
    }
}
