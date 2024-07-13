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
                    BrandSheetRowView(brand: brand) { brand in
                        self.brand = brand
                        dismiss()
                    }
                }
            }

            if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                Section("brand.addBrandForCompany.title \(brandOwner.name)") {
                    ScanTextFieldView(title: "brand.name.placeholder", text: $brandName)
                    AsyncButton("labels.create", action: { await createNewBrand() })
                        .disabled(!brandName.isValidLength(.normal(allowEmpty: false)))
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
        do {
            let brandsWithSubBrands = try await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id)
            self.brandsWithSubBrands = brandsWithSubBrands
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to load brands for \(brandOwner.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func createNewBrand() async {
        do {
            let brandWithSubBrands = try await repository.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id))
            router.open(.toast(.success("brand.created.toast")))
            if mode == .new {
                router.fetchAndNavigateTo(repository, .brand(id: brandWithSubBrands.id))
            }
            brand = brandWithSubBrands
            dismiss()
        } catch {
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
