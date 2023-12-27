import Models
import OSLog
import PhotosUI
import SwiftUI

struct CSVFile: FileDocument {
    static let readableContentTypes = [UTType.commaSeparatedText]
    static let writableContentTypes = UTType.commaSeparatedText
    let text: String

    init(initialText: String = "") {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

@MainActor func isPadOrMac() -> Bool {
    [.pad, .mac].contains(UIDevice.current.userInterfaceIdiom)
}

@MainActor func isMac() -> Bool {
    UIDevice.current.userInterfaceIdiom == .mac
}

func getPagination(page: Int, size: Int) -> (Int, Int) {
    let limit = size + 1
    let from = page * limit
    let to = from + size
    return (from, to)
}

struct IsPortrait: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isPortrait: Bool {
        get { self[IsPortrait.self] }
        set { self[IsPortrait.self] = newValue }
    }
}