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
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var alertError: AlertError?
    @State private var selectedLogo: PhotosPickerItem?
    @State private var logoFile: String?

    let product: Product.Joined
    let onUpload: () async -> Void

    init(product: Product.Joined, onUpload: @escaping () async -> Void) {
        self.product = product
        self.onUpload = onUpload
        _logoFile = State(initialValue: product.logoFile)
    }

    var body: some View {
        Form {
            Section("Select Logo") {
                PhotosPicker(
                    selection: $selectedLogo,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    if let logoFile, let logoUrl = URL(
                        bucket: .productLogos,
                        fileName: logoFile
                    ) {
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
            await uploadLogo()
        }
        .navigationTitle("Product Logo")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }

    func uploadLogo() async {
        guard let data = await selectedLogo?.getJPEG() else { return }
        switch await repository.product.uploadLogo(productId: product.id, data: data) {
        case let .success(filename):
            logoFile = filename
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init(title: "Uplodaing product logo failed.")
            logger.error("Uplodaing product logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
