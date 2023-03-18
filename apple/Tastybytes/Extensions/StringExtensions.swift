import SwiftUI

extension String? {
  var orEmpty: String {
    self ?? ""
  }
}

extension String {
  func asQRCode() -> Data? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data(using: .ascii, allowLossyConversion: false), forKey: "inputMessage")
    guard let ciimage = filter.outputImage else { return nil }
    return UIImage(ciImage: ciimage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))).pngData()
  }
}
