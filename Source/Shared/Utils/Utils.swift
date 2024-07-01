import Models
import OSLog
import PhotosUI
import SwiftUI

struct CSVFile: FileDocument {
    static let readableContentTypes = [UTType.commaSeparatedText]
    static let writableContentTypes = UTType.commaSeparatedText

    let content: String

    init(content: String) {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(decoding: data, as: UTF8.self)
        } else {
            content = ""
        }
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: .init(content.utf8))
    }
}

extension UIDevice {
    static var isMac: Bool {
        UIDevice.current.userInterfaceIdiom == .mac
    }
}
