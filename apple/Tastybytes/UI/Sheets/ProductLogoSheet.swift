import OSLog
import PhotosUI
import SwiftUI

struct ProductLogoSheet: View {
    private let logger = Logger(category: "ProductLogoSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLogo: PhotosPickerItem? {
        didSet {
            Task { await uploadLogo() }
        }
    }

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
                        bucketId: Product.getQuery(.logoBucket),
                        fileName: logoFile
                    ) {
                        AsyncImage(url: logoUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 52, height: 52)
                                .accessibility(hidden: true)
                        } placeholder: {
                            Image(systemSymbol: .photo)
                                .accessibility(hidden: true)
                        }
                    } else {
                        Image(systemSymbol: .photo)
                            .accessibility(hidden: true)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
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
            feedbackManager.toggle(.error(.unexpected))
            logger.error("uplodaing product logo failed. error: \(error)")
        }
    }
}
