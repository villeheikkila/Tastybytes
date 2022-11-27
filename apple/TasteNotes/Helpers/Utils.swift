import Foundation
import SwiftUI
import PhotosUI

func printData(data: Data) {
    print("DATA: ", String(data: data, encoding: String.Encoding.utf8) ?? "")
}

func getPagination(page: Int, size: Int) -> (Int, Int) {
    let limit = size + 1
    let from = page * limit
    let to = from + size
    return (from, to)
}

func getConsistentColor(seed: String) -> Color {
    var total: Int = 0
    for u in seed.unicodeScalars {
        total += Int(UInt32(u))
    }
    srand48(total * 200)
    let r = CGFloat(drand48())
    srand48(total)
    let g = CGFloat(drand48())
    srand48(total / 200)
    let b = CGFloat(drand48())
    return Color(red: r, green: g, blue: b)
}

enum StrinLengthType {
    case normal
    case long
}

func validateStringLength(str: String, type: StrinLengthType) -> Bool {
    switch type {
    case .normal:
        return str.count > 1 && str.count <= 100
    case .long:
        return str.count > 1 && str.count <= 1024
    }
}

enum DateParsingError: Error {
    case failure
}


func parseDate(from: String) throws -> Date {
    let formatter = ISO8601DateFormatter()
    
    formatter.formatOptions = [
        .withInternetDateTime,
        .withFractionalSeconds,
    ]
    
    guard let date = formatter.date(from: from) else { throw DateParsingError.failure }
    return date
}

struct CSVFile: FileDocument {
    static var readableContentTypes = [UTType.commaSeparatedText]
    static var writableContentTypes = UTType.commaSeparatedText
    var text = ""
    
    init(initialText: String = "") {
        text = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct IntId: Decodable {
    let id: Int
}

func joinOptionalStrings(_ arr: [String?]) -> String {
    return arr.compactMap({ $0 }).joined(separator: " ")
}


func formatRating(_ rating: Double?) -> String {
    return String(format: "%.2f", rating ?? "")
}

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
    return withTableName ? "\(tableName) (\(query))" : query
}

func joinWithComma(_ arr: String...) -> String {
    return arr.joined(separator: ", ")
}

func getAvatarURL(id: UUID, avatarUrl: String?) -> URL? {
    if let avatarUrl = avatarUrl {
        let bucketId = "avatars"
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(id.uuidString.lowercased())/\(avatarUrl)"
        guard let url = URL(string: urlString) else { return nil }
        return url
    } else {
        return nil
    }
}

func getCurrentAppIcon() -> AppIcon {
    if let alternateAppIcon = UIApplication.shared.alternateIconName {
        return AppIcon(rawValue: alternateAppIcon) ?? AppIcon.ramune
    } else {
        return AppIcon.ramune
    }
}
