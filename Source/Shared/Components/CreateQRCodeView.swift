import SwiftUI

@MainActor
public struct CreateQRCodeView: View {
    let qrCodeText: String

    public init(qrCodeText: String) {
        self.qrCodeText = qrCodeText
    }

    public var body: some View {
        Group {
            if let qrCode = qrCodeText.asQRCode(), let uiImage = UIImage(data: qrCode) {
                Image(uiImage: uiImage)
                    .resizable()
                    .accessibilityLabel("qrcode.label")

            } else {
                Image(systemName: "qrcode")
                    .resizable()
                    .accessibilityLabel("qrcode.placeholder.label")
            }
        }
        .frame(width: 180, height: 180)
        .cornerRadius(12)
    }
}
