import os
import PhotosUI
import SwiftUI
// swiftlint:disable all
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
    .withFractionalSeconds
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

func joinOptionalStrings(_ arr: [String?]) -> String {
  arr.compactMap { $0 }.joined(separator: " ")
}

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
  withTableName ? "\(tableName) (\(query))" : query
}

func joinWithComma(_ arr: String...) -> String {
  arr.joined(separator: ", ")
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

extension UIImage {
  public func blurHash(numberOfComponents components: (Int, Int)) -> String? {
    let pixelWidth = Int(round(size.width))
    let pixelHeight = Int(round(size.height))

    let context = CGContext(
      data: nil,
      width: pixelWidth,
      height: pixelHeight,
      bitsPerComponent: 8,
      bytesPerRow: pixelWidth * 4,
      space: CGColorSpace(name: CGColorSpace.sRGB)!,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: -size.height)

    UIGraphicsPushContext(context)
    draw(at: .zero)
    UIGraphicsPopContext()

    guard let cgImage = context.makeImage(),
          let dataProvider = cgImage.dataProvider,
          let data = dataProvider.data,
          let pixels = CFDataGetBytePtr(data)
    else {
      assertionFailure("Unexpected error!")
      return nil
    }

    let width = cgImage.width
    let height = cgImage.height
    let bytesPerRow = cgImage.bytesPerRow

    var factors: [(Float, Float, Float)] = []
    for y in 0 ..< components.1 {
      for x in 0 ..< components.0 {
        let normalisation: Float = (x == 0 && y == 0) ? 1 : 2
        let factor = multiplyBasisFunction(
          pixels: pixels,
          width: width,
          height: height,
          bytesPerRow: bytesPerRow,
          bytesPerPixel: cgImage.bitsPerPixel / 8,
          pixelOffset: 0
        ) {
          normalisation * cos(Float.pi * Float(x) * $0 / Float(width)) as Float *
            cos(Float.pi * Float(y) * $1 / Float(height)) as Float
        }
        factors.append(factor)
      }
    }

    let dc = factors.first!
    let ac = factors.dropFirst()

    var hash = ""

    let sizeFlag = (components.0 - 1) + (components.1 - 1) * 9
    hash += sizeFlag.encode83(length: 1)

    let maximumValue: Float
    if ac.count > 0 {
      let actualMaximumValue = ac.map { max(abs($0.0), abs($0.1), abs($0.2)) }.max()!
      let quantisedMaximumValue = Int(max(0, min(82, floor(actualMaximumValue * 166 - 0.5))))
      maximumValue = Float(quantisedMaximumValue + 1) / 166
      hash += quantisedMaximumValue.encode83(length: 1)
    } else {
      maximumValue = 1
      hash += 0.encode83(length: 1)
    }

    hash += encodeDC(dc).encode83(length: 4)

    for factor in ac {
      hash += encodeAC(factor, maximumValue: maximumValue).encode83(length: 2)
    }

    return hash
  }

  private func multiplyBasisFunction(
    pixels: UnsafePointer<UInt8>,
    width: Int,
    height: Int,
    bytesPerRow: Int,
    bytesPerPixel: Int,
    pixelOffset: Int,
    basisFunction: (Float, Float) -> Float
  ) -> (Float, Float, Float) {
    var r: Float = 0
    var g: Float = 0
    var b: Float = 0

    let buffer = UnsafeBufferPointer(start: pixels, count: height * bytesPerRow)

    for x in 0 ..< width {
      for y in 0 ..< height {
        let basis = basisFunction(Float(x), Float(y))
        r += basis * sRGBToLinear(buffer[bytesPerPixel * x + pixelOffset + 0 + y * bytesPerRow])
        g += basis * sRGBToLinear(buffer[bytesPerPixel * x + pixelOffset + 1 + y * bytesPerRow])
        b += basis * sRGBToLinear(buffer[bytesPerPixel * x + pixelOffset + 2 + y * bytesPerRow])
      }
    }

    let scale = 1 / Float(width * height)

    return (r * scale, g * scale, b * scale)
  }
}

private func encodeDC(_ value: (Float, Float, Float)) -> Int {
  let roundedR = linearTosRGB(value.0)
  let roundedG = linearTosRGB(value.1)
  let roundedB = linearTosRGB(value.2)
  return (roundedR << 16) + (roundedG << 8) + roundedB
}

private func encodeAC(_ value: (Float, Float, Float), maximumValue: Float) -> Int {
  let quantR = Int(max(0, min(18, floor(signPow(value.0 / maximumValue, 0.5) * 9 + 9.5))))
  let quantG = Int(max(0, min(18, floor(signPow(value.1 / maximumValue, 0.5) * 9 + 9.5))))
  let quantB = Int(max(0, min(18, floor(signPow(value.2 / maximumValue, 0.5) * 9 + 9.5))))

  return quantR * 19 * 19 + quantG * 19 + quantB
}

private func signPow(_ value: Float, _ exp: Float) -> Float {
  copysign(pow(abs(value), exp), value)
}

private func linearTosRGB(_ value: Float) -> Int {
  let v = max(0, min(1, value))
  if v <= 0.0031308 { return Int(v * 12.92 * 255 + 0.5) }
  else { return Int((1.055 * pow(v, 1 / 2.4) - 0.055) * 255 + 0.5) }
}

private func sRGBToLinear(_ value: some BinaryInteger) -> Float {
  let v = Float(Int64(value)) / 255
  if v <= 0.04045 { return v / 12.92 }
  else { return pow((v + 0.055) / 1.055, 2.4) }
}

private let encodeCharacters: [String] =
  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~".map { String($0) }

extension BinaryInteger {
  func encode83(length: Int) -> String {
    var result = ""
    for i in 1 ... length {
      let digit = (Int(self) / pow(83, length - i)) % 83
      result += encodeCharacters[Int(digit)]
    }
    return result
  }
}

private func pow(_ base: Int, _ exponent: Int) -> Int {
  (0 ..< exponent).reduce(1) { value, _ in value * base }
}

extension UIImage {
  func resized(to newSize: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: newSize)

    let image = renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
    return image
  }
}
