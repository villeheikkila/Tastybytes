import SwiftUI

@MainActor
public struct CreateQRCodeView: View {
    @State private var qrCodeImageData: Data?
    let qrCodeText: String

    public init(qrCodeText: String) {
        self.qrCodeText = qrCodeText
    }

    public var body: some View {
        HStack(alignment: .center) {
            if let qrCode = qrCodeImageData, let uiImage = UIImage(data: qrCode) {
                Image(uiImage: uiImage)
                    .resizable()
                    .accessibilityLabel("qrcode.label")

            } else {
                ProgressView()
            }
        }
        .frame(width: 180, height: 180)
        .cornerRadius(12)
        .initialTask {
            qrCodeImageData = await qrCodeText.asQRCode()
        }
    }
}
