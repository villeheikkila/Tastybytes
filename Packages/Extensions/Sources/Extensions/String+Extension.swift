import SwiftUI

public extension String? {
    var isNilOrEmpty: Bool {
        // swiftlint:disable empty_string
        self == nil || self == ""
        // swiftlint:enable empty_string
    }
}

public extension String {
    enum StrinLengthType {
        case normal
        case long
    }

    func isValidLength(_ type: StrinLengthType) -> Bool {
        switch type {
        case .normal:
            isValidLength(minLength: 1, maxLength: 100)
        case .long:
            isValidLength(minLength: 1, maxLength: 1024)
        }
    }

    func isValidLength(minLength: Int, maxLength: Int) -> Bool {
        let length = count
        return length >= minLength && length <= maxLength
    }
}

public extension String? {
    var orEmpty: String {
        self ?? ""
    }
}

#if !os(watchOS)
    public extension String {
        func asQRCode() -> Data? {
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            filter.setValue(data(using: .ascii, allowLossyConversion: false), forKey: "inputMessage")
            guard let ciimage = filter.outputImage else { return nil }
            return UIImage(ciImage: ciimage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))).pngData()
        }
    }
#endif

public extension String {
    func formatStringEveryWordCapitalized() -> String {
        lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .compactMap { $0.capitalized(with: Locale.current) }
            .joined(separator: " ")
    }
}

public extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
