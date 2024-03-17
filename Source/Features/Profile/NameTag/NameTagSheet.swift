import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct NameTagSheet: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var showNameTagScanner = false

    let onSuccess: (_ profileId: UUID) -> Void

    var body: some View {
        VStack(spacing: 20) {
            if !showNameTagScanner {
                CreateQRCodeView(qrCodeText: NavigatablePath.profile(id: profileEnvironmentModel.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl).absoluteString)
                Button(action: { showNameTagScanner.toggle() }, label: {
                    HStack {
                        Spacer()
                        Label("nameTag.scan.label", systemImage: "qrcode.viewfinder")
                        Spacer()
                    }
                })
            } else {
                #if !targetEnvironment(macCatalyst)
                DataScannerViewRepresentable(recognizedDataTypes: [.barcode(symbologies: [.qr])]) { data in
                    if case let .barcode(foundBarcode) = data, let qrCode = foundBarcode.payloadStringValue {
                        let string = qrCode.components(separatedBy: "/").last
                        if let string, let profileId = UUID(uuidString: string) {
                            dismiss()
                            onSuccess(profileId)
                        }
                    }
                }
                #endif
                Button(action: { showNameTagScanner.toggle() }, label: {
                    HStack {
                        Spacer()
                        Label("nameTag.show.label", systemImage: "qrcode")
                        Spacer()
                    }

                })
            }
        }
        .navigationTitle("nameTag.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .topBarTrailing) {
            ProfileShareLinkView(profile: profileEnvironmentModel.profile)
        }
    }
}
