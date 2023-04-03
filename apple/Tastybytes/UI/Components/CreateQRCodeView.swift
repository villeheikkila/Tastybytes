import SwiftUI

struct CreateQRCodeView: View {
  let qrCodeText: String

  var body: some View {
    if let qrCode = qrCodeText.asQRCode(), let uiImage = UIImage(data: qrCode) {
      Image(uiImage: uiImage)
        .resizable()
        .frame(width: 180, height: 180)
        .accessibilityLabel("qr code")
        .cornerRadius(12)
    } else {
      Image(systemName: "qrcode")
        .resizable()
        .frame(width: 180, height: 180)
        .accessibilityLabel("placeholder qr code")
        .cornerRadius(12)
    }
  }
}
