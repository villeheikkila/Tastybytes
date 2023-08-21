import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct SubBrandSheet: View {
    private let logger = Logger(category: "SubBrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var subBrandName = ""
    @State private var searchText: String = ""
    @Binding var subBrand: SubBrandProtocol?

    let brandWithSubBrands: Brand.JoinedSubBrands

    var filteredSubBrands: [SubBrand] {
        brandWithSubBrands.subBrands.sorted()
            .filter { sub in
                guard let name = sub.name else { return false }
                return searchText.isEmpty || name.contains(searchText) == true
            }
    }

    var body: some View {
        List {
            ForEach(filteredSubBrands) { subBrand in
                if let name = subBrand.name {
                    Button(name, action: {
                        self.subBrand = subBrand
                        dismiss()
                    })
                }
            }

            if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                Section("Add new sub-brand for \(brandWithSubBrands.name)") {
                    ScanTextField(title: "Name", text: $subBrandName)
                    ProgressButton("Create", action: { await createNewSubBrand() })
                        .disabled(!subBrandName.isValidLength(.normal))
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Sub-brands")
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

    func createNewSubBrand() async {
        switch await repository.subBrand
            .insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brandWithSubBrands.id))
        {
        case let .success(newSubBrand):
            feedbackEnvironmentModel.toggle(.success("New Sub-brand Created!"))
            await MainActor.run {
                subBrand = newSubBrand
                dismiss()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Saving sub-brand failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
