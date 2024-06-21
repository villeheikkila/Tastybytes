import Foundation

public extension Error {
    var isCancelled: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}

public extension Error {
    var isNotConnectedToInternet: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet
    }

    var isSSLFailure: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorSecureConnectionFailed
    }

    var isTimeOut: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
    }

    var isCannotFindHost: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCannotFindHost
    }

    var isCannotConnectToHost: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCannotConnectToHost
    }

    var isDNSLookupFailure: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorDNSLookupFailed
    }

    var isNetworkConnectionLost: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNetworkConnectionLost
    }

    var isNetworkUnavailable: Bool {
        isNotConnectedToInternet || isNetworkConnectionLost || isSSLFailure || isTimeOut || isCannotFindHost || isCannotConnectToHost || isDNSLookupFailure || isNotConnectedToInternet
    }
}

public extension Array where Element: Error {
    var isNetworkUnavailable: Bool {
        for error in self where error.isNetworkUnavailable {
            return true
        }
        return false
    }
}
