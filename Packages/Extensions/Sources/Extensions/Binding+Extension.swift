import SwiftUI

public extension Binding {
    func isNotNull<V>() -> Binding<Bool> where Value == V? {
        Binding<Bool>(get: { self.wrappedValue != nil },
                      set: { _ in self.wrappedValue = nil })
    }

    func map<V>(getter: @escaping @Sendable (Value) -> V, setter: @escaping @Sendable (V) -> Value) -> Binding<V> {
        Binding<V>(get: { getter(self.wrappedValue) },
                   set: { self.wrappedValue = setter($0) })
    }
}
