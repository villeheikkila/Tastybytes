import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct SubBrandSheet: View {
    private let logger = Logger(category: "SubBrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var subBrandName = ""
    @State private var searchTerm: String = ""
    @Binding var subBrand: SubBrandProtocol?

    let brandWithSubBrands: Brand.JoinedSubBrands

    private var sortedSubBrands: [SubBrand] {
        brandWithSubBrands.subBrands.sorted().filter { $0.name != nil }
    }

    private var filteredSubBrands: [SubBrand] {
        sortedSubBrands.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredSubBrands.isEmpty
    }

    var body: some View {
        List {
            ForEach(filteredSubBrands) { subBrand in
                SubBrandSheetRowView(subBrand: subBrand) { _ in
                    self.subBrand = subBrand
                    dismiss()
                }
            }

            if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                Section("subBrand.addSubBrandFor.title \(brandWithSubBrands.name)") {
                    ScanTextFieldView(title: "subBrand.name.placeholder", text: $subBrandName)
                    AsyncButton("labels.create", action: { await createNewSubBrand() })
                        .disabled(!subBrandName.isValidLength(.normal(allowEmpty: false)))
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("subBrand.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func createNewSubBrand() async {
        do {
            let newSubBrand = try await repository.subBrand.insert(newSubBrand: .init(name: subBrandName, brandId: brandWithSubBrands.id))
            router.open(.toast(.success("subBrand.create.success.toast")))
            subBrand = newSubBrand
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Saving sub-brand failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
