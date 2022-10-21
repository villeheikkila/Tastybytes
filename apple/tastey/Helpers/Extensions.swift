import SwiftUI

extension Array where Element: Equatable {
 mutating func remove(object: Element) {
     guard let index = firstIndex(of: object) else {return}
     remove(at: index)
 }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}

