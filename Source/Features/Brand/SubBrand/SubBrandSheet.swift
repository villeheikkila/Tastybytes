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
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var subBrandName = ""
    @State private var searchTerm: String = ""
    @Binding var subBrand: SubBrandProtocol?

    let brandWithSubBrands: Brand.JoinedSubBrands

    var filteredSubBrands: [SubBrand] {
        brandWithSubBrands.subBrands.sorted()
            .filter { sub in
                guard let name = sub.name else { return false }
                return searchTerm.isEmpty || name.lowercased().contains(searchTerm.lowercased())
            }
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredSubBrands.isEmpty
    }

    var body: some View {
        List {
            ForEach(filteredSubBrands) { subBrand in
                SubBrandSheetRow(subBrand: subBrand) { _ in
                    self.subBrand = subBrand
                    dismiss()
                }
            }

            if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                Section("subBrand.addSubBrandFor.title \(brandWithSubBrands.name)") {
                    ScanTextField(title: "subBrand.name.placeholder", text: $subBrandName)
                    ProgressButton("labels.create", action: { await createNewSubBrand() })
                        .disabled(!subBrandName.isValidLength(.normal))
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

    func createNewSubBrand() async {
        switch await repository.subBrand
            .insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brandWithSubBrands.id))
        {
        case let .success(newSubBrand):
            feedbackEnvironmentModel.toggle(.success("subBrand.create.success.toast"))
            subBrand = newSubBrand
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Saving sub-brand failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
