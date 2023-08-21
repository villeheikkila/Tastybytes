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

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
    withTableName ? "\(tableName) (\(query))" : query
}

func isPadOrMac() -> Bool {
    [.pad, .mac].contains(UIDevice.current.userInterfaceIdiom)
}

func isMac() -> Bool {
    UIDevice.current.userInterfaceIdiom == .mac
}

func getPagination(page: Int, size: Int) -> (Int, Int) {
    let limit = size + 1
    let from = page * limit
    let to = from + size
    return (from, to)
}

func clearTemporaryData() {
    let logger = Logger(category: "TempDataCleanUp")
    // Reset tab restoration
    UserDefaults.standard.removeObject(for: .selectedTab)

    // Reset NavigationStack restoration
    let fileEnvironmentModel = FileManager.default
    let filesToDelete = Tab.allCases.map(\.cachesPath)
    do {
        let directoryContents = try fileEnvironmentModel.contentsOfDirectory(
            at: URL.cachesDirectory,
            includingPropertiesForKeys: nil,
            options: []
        )
        for file in directoryContents where filesToDelete.contains(file.lastPathComponent) {
            try fileEnvironmentModel.removeItem(at: file)
        }
    } catch {
        logger.error("Failed to delete navigation stack state restoration files. Error: \(error) (\(#file):\(#line))")
    }
}
