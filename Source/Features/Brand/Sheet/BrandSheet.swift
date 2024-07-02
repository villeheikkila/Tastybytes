import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandSheet: View {
    private let logger = Logger(category: "BrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var brandsWithSubBrands = [Brand.JoinedSubBrands]()
    @State private var brandName = ""
    @State private var searchTerm: String = ""

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
                    BrandSheetRow(brand: brand) { brand in
                        self.brand = brand
                        dismiss()
                    }
                }
            }

            if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                Section("brand.addBrandForCompany.title \(brandOwner.name)") {
                    ScanTextField(title: "brand.name.placeholder", text: $brandName)
                    ProgressButton("labels.create", action: { await createNewBrand() })
                        .disabled(!brandName.isValidLength(.normal))
                }
            }
        }
        .listStyle(.plain)
        .foregroundColor(.primary)
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle(mode.navigationTitle)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            toolbarContent
        }
        .task {
            await loadBrands(brandOwner)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func loadBrands(_ brandOwner: Company) async {
        switch await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id) {
        case let .success(brandsWithSubBrands):
            self.brandsWithSubBrands = brandsWithSubBrands
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to load brands for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func createNewBrand() async {
        switch await repository.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id)) {
        case let .success(brandWithSubBrands):
            feedbackEnvironmentModel.toggle(.success("brand.created.toast"))
            if mode == .new {
                router.fetchAndNavigateTo(repository, .brand(id: brandWithSubBrands.id))
            }
            brand = brandWithSubBrands
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to create new brand for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension BrandSheet {
    enum Mode: Sendable {
        case select, new

        var navigationTitle: LocalizedStringKey {
            switch self {
            case .new:
                "brand.add.navigationTitle"
            case .select:
                "brand.select.navigationTitle"
            }
        }
    }
}
