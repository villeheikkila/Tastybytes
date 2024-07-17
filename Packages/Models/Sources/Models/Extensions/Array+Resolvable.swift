import Foundation

public protocol Resolvable {
    var resolvedAt: Date? { get }
}

public extension Array where Element: Resolvable {
    var unresolvedCount: Int {
        filter { $0.resolvedAt == nil }.count
    }
}
