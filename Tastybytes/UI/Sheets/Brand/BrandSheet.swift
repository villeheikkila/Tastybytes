import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandSheet: View {
    private let logger = Logger(category: "BrandSheet")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var brandsWithSubBrands = [Brand.JoinedSubBrands]()
    @State private var brandName = ""
    @State private var searchText: String = ""
    @Binding var brand: Brand.JoinedSubBrands?

    let brandOwner: Company
    let mode: Mode

    var filteredBrands: [Brand.JoinedSubBrands] {
        brandsWithSubBrands.filter { searchText.isEmpty || $0.name.contains(searchText) == true }
    }

    var body: some View {
        List {
            if mode == .select {
                ForEach(filteredBrands) { brand in
                    Button(brand.name, action: {
                        self.brand = brand
                        dismiss()
                    })
                }
            }

            if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                Section("Add new brand for \(brandOwner.name)") {
                    ScanTextField(title: "Name", text: $brandName)
                    ProgressButton("Create", action: { await createNewBrand() })
                        .disabled(!brandName.isValidLength(.normal))
                }
            }
        }
        .navigationTitle("\(mode == .select ? "Select" : "Add") brand")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            toolbarContent
        }
        .task {
            await loadBrands(brandOwner)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }

    func loadBrands(_ brandOwner: Company) async {
        switch await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id) {
        case let .success(brandsWithSubBrands):
            await MainActor.run {
                self.brandsWithSubBrands = brandsWithSubBrands
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to load brands for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func createNewBrand() async {
        switch await repository.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id)) {
        case let .success(brandWithSubBrands):
            feedbackEnvironmentModel.toggle(.success("New Brand Created!"))
            if mode == .new {
                router.fetchAndNavigateTo(repository, .brand(id: brandWithSubBrands.id))
            }
            await MainActor.run {
                brand = brandWithSubBrands
                dismiss()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to create new brand for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension BrandSheet {
    enum Mode {
        case select, new
    }
}
