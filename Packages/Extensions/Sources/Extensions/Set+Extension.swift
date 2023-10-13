import Foundation

public extension Set {
    func addedValueTo(_ to: Set<Element>) -> Element? {
        guard count > to.count else { return nil }
        let addedFlavor = subtracting(to)
        return Array(addedFlavor).first
    }
}
