import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProductLogoSheet: View {
    private let logger = Logger(category: "ProductLogoSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var alertError: AlertError?
    @State private var selectedLogo: PhotosPickerItem?
    @State private var product: Product.Joined

    let onUpload: () async -> Void

    init(product: Product.Joined, onUpload: @escaping () async -> Void) {
        _product = State(initialValue: product)
        self.onUpload = onUpload
    }

    var body: some View {
        Form {
            Section("Select Logo") {
                PhotosPicker(
                    selection: $selectedLogo,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    if let logoUrl = product.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                        RemoteImage(url: logoUrl) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 52, height: 52)
                                    .accessibility(hidden: true)
                            } else {
                                Image(systemName: "photo")
                                    .accessibility(hidden: true)
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .accessibility(hidden: true)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .alertError($alertError)
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await uploadLogo(data: data)
        }
        .navigationTitle("product.logo.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func uploadLogo(data: Data) async {
        switch await repository.product.uploadLogo(productId: product.id, data: data) {
        case let .success(imageEntity):
            product = product.copyWith(logos: product.logos + [imageEntity])
            logger.info("Succesfully uploaded image \(imageEntity.file)")
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init(title: "Uploading of a product logo failed.")
            logger.error("Uploading of a product logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
