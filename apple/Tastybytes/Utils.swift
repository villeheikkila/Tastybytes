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

struct IntId: Decodable {
  let id: Int
}

func joinOptionalStrings(_ arr: [String?]) -> String {
  arr.compactMap { $0 }.joined(separator: " ")
}

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
  withTableName ? "\(tableName) (\(query))" : query
}

func joinWithComma(_ arr: String...) -> String {
  arr.joined(separator: ", ")
}

func getCurrentAppIcon() -> AppIcon {
  if let alternateAppIcon = UIApplication.shared.alternateIconName {
    return AppIcon(rawValue: alternateAppIcon) ?? AppIcon.ramune
  } else {
    return AppIcon.ramune
  }
}

struct OptionalNavigationLink<RootView: View>: View {
  let value: Route
  let disabled: Bool
  let view: () -> RootView

  init(
    value: Route,
    disabled: Bool,
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
    self.value = value
    self.disabled = disabled
  }

  var body: some View {
    if disabled {
      view()

    } else {
      NavigationLink(value: value) {
        view()
      }
      .buttonStyle(.plain)
    }
  }
}

func getLogger(category: String) -> Logger {
  Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "app",
    category: category
  )
}

func generateQrCode(_ content: String) -> Data? {
  guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
  filter.setValue(content.data(using: .ascii, allowLossyConversion: false), forKey: "inputMessage")
  guard let ciimage = filter.outputImage else { return nil }
  return UIImage(ciImage: ciimage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))).pngData()
}
