import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct SubBrandPickerSheet: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchTerm: String = ""
    @Binding var subBrand: SubBrandProtocol?

    let brandWithSubBrands: Brand.JoinedSubBrands

    private var sortedSubBrands: [SubBrand.Saved] {
        brandWithSubBrands.subBrands.sorted().filter { $0.name != nil }
    }

    private var filteredSubBrands: [SubBrand.Saved] {
        sortedSubBrands.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredSubBrands.isEmpty
    }

    var body: some View {
        List(filteredSubBrands) { subBrand in
            SubBrandSheetRowView(subBrand: subBrand) { _ in
                self.subBrand = subBrand
                dismiss()
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .safeAreaInset(edge: .bottom, content: {
            if profileModel.hasPermission(.canCreateBrands) {
                CreateSubBrandView(brandWithSubBrands: brandWithSubBrands) { subBrand in
                    self.subBrand = subBrand
                    dismiss()
                }
            }
        })
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("subBrand.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}

struct CreateSubBrandView: View {
    private let logger = Logger(category: "CreateSubBrandView")
    @Environment(Repository.self) private var repository
    @State private var subBrandName = ""
    @State private var includesBrandName = false
    @Environment(Router.self) private var router

    let brandWithSubBrands: Brand.JoinedSubBrands
    let onCreate: (SubBrand.Saved) -> Void

    private var isValidName: Bool {
        subBrandName.isValidLength(.normal(allowEmpty: false))
    }

    var body: some View {
        Form {
            Section("subBrand.addSubBrandFor.title \(brandWithSubBrands.name)") {
                ScanTextFieldView(title: "subBrand.name.placeholder", text: $subBrandName)
                Toggle("subBrand.includesBrandName.toggle.label", isOn: $includesBrandName)
                    .disabled(!isValidName)
                AsyncButton("labels.create", action: { await createNewSubBrand() })
                    .disabled(!isValidName)
            }
            .customListRowBackground()
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: 8))
        .padding()
    }

    private func createNewSubBrand() async {
        do {
            let newSubBrand = try await repository.subBrand.insert(
                newSubBrand: .init(
                    name: subBrandName,
                    brandId: brandWithSubBrands.id,
                    includesBrandName: includesBrandName
                )
            )
            router.open(.toast(.success("subBrand.create.success.toast")))
            onCreate(newSubBrand)
        } catch {
            guard !error.isCancelled else { return }
            guard !error.isDuplicate else {
                router.open(.toast(.warning("labels.duplicate.toast")))
                return
            }
            router.open(.alert(.init()))
            logger.error("Saving sub-brand failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
