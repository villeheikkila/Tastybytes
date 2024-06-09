import Foundation

public extension Error {
    var isCancelled: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}

public extension Error {
    var isNetworkUnavailable: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet
    }
}

public extension Array where Element: Error {
    var isNetworkUnavailable: Bool {
        for error in self {
            if error.isNetworkUnavailable {
                return true
            }
        }
        return false
    }
}
