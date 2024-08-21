import SwiftUI

public extension Binding {
    func isNotNull<V>() -> Binding<Bool> where Value == V?, V: Sendable  {
        Binding<Bool>(get: { wrappedValue != nil },
                      set: { _ in wrappedValue = nil })
    }

    @MainActor
    func map<V>(getter: @escaping (Value) -> V, setter: @escaping (V) -> Value) -> Binding<V> {
        Binding<V>(get: { getter(wrappedValue) },
                   set: { wrappedValue = setter($0) })
    }
}
