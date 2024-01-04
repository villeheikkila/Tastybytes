import Components
import EnvironmentModels
import Extensions
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
    @State private var searchTerm: String = ""
    @State private var alertError: AlertError?

    @Binding var brand: Brand.JoinedSubBrands?

    let brandOwner: Company
    let mode: Mode

    var filteredBrands: [Brand.JoinedSubBrands] {
        brandsWithSubBrands.filter { searchTerm.isEmpty || $0.name.contains(searchTerm) == true }
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredBrands.isEmpty
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
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("\(mode == .select ? "Select" : "Add") brand")
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .task {
            await loadBrands(brandOwner)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }

    func loadBrands(_ brandOwner: Company) async {
        switch await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id) {
        case let .success(brandsWithSubBrands):
            self.brandsWithSubBrands = brandsWithSubBrands
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load brands for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    @MainActor
    func createNewBrand() async {
        switch await repository.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id)) {
        case let .success(brandWithSubBrands):
            feedbackEnvironmentModel.toggle(.success("New Brand Created!"))
            if mode == .new {
                router.fetchAndNavigateTo(repository, .brand(id: brandWithSubBrands.id))
            }
            brand = brandWithSubBrands
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to create new brand for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension BrandSheet {
    enum Mode: Sendable {
        case select, new
    }
}
