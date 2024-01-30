import Foundation

enum DataConversionError: Error, LocalizedError {
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidData:
            "Unable to convert data to string"
        }
    }
}
