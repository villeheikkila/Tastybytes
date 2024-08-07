import Foundation

public extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }
}

public extension Array where Element: Equatable {
    func removing(_ item: Element) -> [Element] {
        var result = self
        if let index = result.firstIndex(of: item) {
            result.remove(at: index)
        }
        return result
    }
}

public extension Array where Element: Identifiable {
    func removingWithId(_ item: Element.ID) -> [Element] {
        var newArray = self
        if let toReplace = newArray.firstIndex(where: { $0.id == item }) {
            newArray.remove(at: toReplace)
        }
        return newArray
    }
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

public extension Array {
    func filteredBySearchTerm(
        by keyPath: KeyPath<Element, some StringProtocol>,
        searchTerm: String
    ) -> [Element] {
        guard !searchTerm.isEmpty else { return self }
        return filter { $0[keyPath: keyPath].localizedCaseInsensitiveContains(searchTerm) }
    }
}

public extension Array {
    func filteredBySearchTerm(
        by keyPath: KeyPath<Element, (some StringProtocol)?>,
        searchTerm: String
    ) -> [Element] {
        guard !searchTerm.isEmpty else { return self }
        return filter { $0[keyPath: keyPath]?.localizedCaseInsensitiveContains(searchTerm) ?? false }
    }
}

public extension Array where Element: Equatable {
    func removing(_ items: [Element]) -> [Element] {
        var result = self
        for item in items {
            while let index = result.firstIndex(of: item) {
                result.remove(at: index)
            }
        }
        return result
    }
}

public extension Array where Element: Equatable {
    mutating func replace(_ element: Element, with new: Element) {
        if let toReplace = firstIndex(where: { $0 == element }) {
            self[toReplace] = new
        }
    }
}

public extension Array where Element: Identifiable {
    func replacingWithId(_ id: Element.ID, with new: Element) -> [Element] {
        var newArray = self
        if let toReplace = newArray.firstIndex(where: { $0.id == id }) {
            newArray[toReplace] = new
        }
        return newArray
    }
}

public extension Array where Element: Equatable {
    func replacing(_ element: Element, with new: Element) -> [Element] {
        var newArray = self
        if let toReplace = newArray.firstIndex(where: { $0 == element }) {
            newArray[toReplace] = new
        }
        return newArray
    }
}

public extension Array {
    func unique(selector: (Element, Element) -> Bool) -> [Element] {
        reduce([Element]()) { result, element in
            if let last = result.last {
                selector(last, element) ? result : result + [element]
            } else {
                [element]
            }
        }
    }
}

public extension Array {
    func joinOptionalSpace<T>() -> String where T: ExpressibleByStringLiteral, Element == T? {
        compactMap { $0 as? String }.joined(separator: " ")
    }
}

public extension Sequence {
    func grouped<T: Hashable>(by key: (Element) -> T) -> [T: [Element]] {
        Dictionary(grouping: self, by: key)
    }
}
