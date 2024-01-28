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

public extension Array where Element: Equatable {
    mutating func replace(_ element: Element, with new: Element) {
        if let toReplace = firstIndex(where: { $0 == element }) {
            self[toReplace] = new
        }
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

public extension [String] {
    func joinComma() -> String {
        joined(separator: ", ")
    }
}

public extension Array {
    func joinOptionalSpace<T>() -> String where T: ExpressibleByStringLiteral, Element == T? {
        compactMap { $0 as? String }.joined(separator: " ")
    }
}
