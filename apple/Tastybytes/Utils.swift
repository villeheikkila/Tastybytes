import os
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

