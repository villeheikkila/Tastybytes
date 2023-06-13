import SwiftUI

struct NameTagSheet: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(\.dismiss) private var dismiss
    @State private var showNameTagScanner = false

    let onSuccess: (_ profileId: UUID) -> Void

    var body: some View {
        VStack(spacing: 20) {
            if !showNameTagScanner {
                CreateQRCodeView(qrCodeText: NavigatablePath.profile(id: profileManager.id).url.absoluteString)
                Button(action: { showNameTagScanner.toggle() }, label: {
                    HStack {
                        Spacer()
                        Label("Scan Name Tag", systemSymbol: .qrcodeViewfinder)
                        Spacer()
                    }
                })
            } else {
                ScannerView(scanTypes: [.qr]) { response in
                    if case let .success(result) = response {
                        let string = result.barcode.components(separatedBy: "/").last
                        if let string, let profileId = UUID(uuidString: string) {
                            dismiss()
                            onSuccess(profileId)
                        }
                    }
                }
                Button(action: { showNameTagScanner.toggle() }, label: {
                    HStack {
                        Spacer()
                        Label("Show Name Tag", systemSymbol: .qrcode)
                        Spacer()
                    }

                })
            }
        }
        .navigationTitle("Name Tag")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Close", role: .cancel, action: { dismiss() })
                .bold()
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProfileShareLinkView(profile: profileManager.profile)
        }
    }
}
