import Components

import Models
import SwiftUI

struct NameTagSheet: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var showNameTagScanner = false

    let onSuccess: (Profile.Id) -> Void

    var body: some View {
        VStack(spacing: 20) {
            if !showNameTagScanner {
                ProfileQRCodeView(id: profileModel.id)
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
                            if let string, let profileId = Profile.Id(uuidString: string) {
                                onSuccess(profileId)
                                dismiss()
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
            ProfileShareLinkView(profile: profileModel.profile)
        }
    }
}

struct ProfileQRCodeView: View {
    @Environment(AppModel.self) private var appModel
    let id: Profile.Id

    var body: some View {
        CreateQRCodeView(qrCodeText: NavigatablePath.profile(id: id).getUrl(baseUrl: appModel.infoPlist.baseUrl).absoluteString)
    }
}
