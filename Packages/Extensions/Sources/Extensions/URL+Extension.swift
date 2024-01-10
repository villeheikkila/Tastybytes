import Foundation

public extension URL {
    init(staticString: StaticString) {
        // swiftlint:disable force_unwrapping
        self.init(string: "\(staticString)")!
        // swiftlint:enable force_unwrapping
    }
}
