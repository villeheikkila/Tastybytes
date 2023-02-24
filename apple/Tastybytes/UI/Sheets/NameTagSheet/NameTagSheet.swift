import SwiftUI

struct NameTagSheet: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var showNameTagScanner = false
  @State private var showProfileQrCode = false

  let onSuccess: (_ profileId: UUID) -> Void

  var body: some View {
    VStack(spacing: 20) {
      if !showNameTagScanner {
        CreateQRCodeView(qrCodeText: NavigatablePath.profile(id: profileManager.getId()).url.absoluteString)
        Button(action: { showNameTagScanner.toggle() }, label: {
          HStack {
            Spacer()
            Label("Scan Name Tag", systemImage: "qrcode.viewfinder")
            Spacer()
          }
        })
      } else {
        ScannerView(scanTypes: [.qr]) { response in
          if case let .success(result) = response {
            let string = result.barcode.components(separatedBy: "/").last
            if let string, let profileId = UUID(uuidString: string) {
              onSuccess(profileId)
            }
          }
        }
        Button(action: { showNameTagScanner.toggle() }, label: {
          HStack {
            Spacer()
            Label("Show Name Tag", systemImage: "qrcode")
            Spacer()
          }

        })
      }
    }
    .navigationTitle("Name Tag")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      trailing: ShareLink("Share", item: NavigatablePath.profile(id: profileManager.getId()).url)
    )
  }
}
