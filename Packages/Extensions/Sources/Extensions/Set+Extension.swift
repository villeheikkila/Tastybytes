import Foundation

public extension Array where Element: Hashable {
    func addedValues(_ to: [Element]) -> [Element] {
        Array(Set(self).subtracting(Set(to)))
    }
}
