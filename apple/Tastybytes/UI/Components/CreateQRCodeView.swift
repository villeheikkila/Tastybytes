import SwiftUI

struct CreateQRCodeView: View {
  let qrCodeText: String

  var body: some View {
    if let qrCode = generateQrCode(qrCodeText), let uiImage = UIImage(data: qrCode) {
      Image(uiImage: uiImage)
        .resizable()
        .frame(width: 200, height: 200)
        .accessibilityLabel("qr code")
    } else {
      Image(systemName: "qrcode")
        .resizable()
        .frame(width: 200, height: 200)
        .accessibilityLabel("placeholder qr code")
    }
  }
}
