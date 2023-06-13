import SwiftUI

struct CreateQRCodeView: View {
    let qrCodeText: String

    var body: some View {
        Group {
            if let qrCode = qrCodeText.asQRCode(), let uiImage = UIImage(data: qrCode) {
                Image(uiImage: uiImage)
                    .resizable()
                    .accessibilityLabel("qr code")

            } else {
                Image(systemSymbol: .qrcode)
                    .resizable()
                    .accessibilityLabel("placeholder qr code")
            }
        }
        .frame(width: 180, height: 180)
        .cornerRadius(12)
    }
}
