extension Array where Element: Equatable {
 mutating func remove(object: Element) {
     guard let index = firstIndex(of: object) else {return}
     remove(at: index)
 }
}
