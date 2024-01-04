import Foundation

extension URL {
    init(_ string: StaticString) {
        // swiftlint:disable force_unwrapping
        self.init(string: "\(string)")!
        // swiftlint:enable force_unwrapping
    }
}
