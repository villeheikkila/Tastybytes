import os
import PhotosUI
import SwiftUI

func getConsistentColor(seed: String) -> Color {
  var total = 0
  for unicodeScalar in seed.unicodeScalars {
    total += Int(UInt32(unicodeScalar))
  }
  srand48(total * 200)
  let red = Double(drand48())
  srand48(total)
  let green = Double(drand48())
  srand48(total / 200)
  let blue = Double(drand48())
  return Color(red: red, green: green, blue: blue)
}

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

func getLogger(category: String) -> Logger {
  Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "app",
    category: category
  )
}

func isPadOrMac() -> Bool {
  [.pad, .mac].contains(UIDevice.current.userInterfaceIdiom)
}
