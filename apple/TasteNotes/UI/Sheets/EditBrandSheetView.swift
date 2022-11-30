import SwiftUI

struct EditBrandSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    @State var name: String
    @State var brandOwner: Company
    @State var editSubBrand: SubBrand.JoinedProduct?

    let brand: Brand.JoinedSubBrandsProducts
    let onUpdate: () -> Void

    init(brand: Brand.JoinedSubBrandsProducts, brandOwner: Company, onUpdate: @escaping () -> Void) {
        self.brand = brand
        _brandOwner = State(initialValue: brandOwner)
        _name = State(initialValue: brand.name)
        self.onUpdate = onUpdate
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .disabled(!validateStringLength(str: name, type: .normal) || brand.name == name)
                Button("Edit") {
                    viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
                        onUpdate()
                    }
                }
            } header: {
                Text("Brand name")
            }

            Section {
                Button(action: {
                    viewModel.activeSheet = Sheet.brandOwner
                }) {
                    Text(brandOwner.name)
                }
            } header: {
                Text("Brand Owner")
            }

            Section {
                ForEach(brand.subBrands, id: \.id) { subBrand in
                    if let subBrandName = subBrand.name {
                        HStack {
                            Text(subBrandName)
                            Spacer()
                            Menu {
                                Button(action: {
                                    editSubBrand = subBrand
                                    viewModel.activeSheet = Sheet.editSubBrand
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(action: {
                                    viewModel.toDeleteSubBrand = subBrand
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                            }
                        }
                    }
                }
            } header: {
                Text("Sub-brands")
            }
        }
        .navigationTitle("Edit Brand")
        .navigationBarItems(trailing: Button(action: {
            dismiss()
        }) {
            Text("Cancel").bold()
        })
        .sheet(item: $viewModel.activeSheet) { sheet in NavigationStack {
            switch sheet {
            case .brandOwner:
                CompanySheetView(onSelect: { company, _ in
                    brandOwner = company
                    viewModel.activeSheet = nil
                })
            case .editSubBrand:
                if let subBrand = editSubBrand {
                    EditSubBrandSheetView(brand: brand, subBrand: subBrand,
                                          onClose: {
                                              viewModel.activeSheet = nil
                                              editSubBrand = nil
                                          })
                }
            }
        }
        }
        .confirmationDialog("Delete Sub-brand",
                            isPresented: $viewModel.showDeleteSubBrandConfirmation) {
            if let toDeleteSubBrand = viewModel.toDeleteSubBrand {
                Button("Delete \(toDeleteSubBrand.name ?? "") and all related products", role: .destructive, action: {
                    viewModel.deleteSubBrand()
                })
            }
        }
    }
}

extension EditBrandSheetView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case brandOwner
        case editSubBrand
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var activeSheet: Sheet?
        @Published var showDeleteSubBrandConfirmation = false
        @Published var toDeleteSubBrand: SubBrand.JoinedProduct? {
            didSet {
                if oldValue != nil {
                    showDeleteSubBrandConfirmation = true
                } else {
                    showDeleteSubBrandConfirmation = false
                }
            }
        }

        func editBrand(brand: Brand.JoinedSubBrandsProducts, name: String, brandOwner: Company, onSuccess: @escaping () -> Void) {
            Task {
                switch await repository.brand.update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id)) {
                case .success:
                    onSuccess()
                case let .failure(error):
                    print(error)
                }
            }
        }
        
        func deleteSubBrand() {
            
        }
    }
}

struct EditSubBrandSheetView: View {
    @StateObject private var viewModel = ViewModel()
    @State var newSubBrandName: String
    
    let brand: Brand.JoinedSubBrandsProducts
    let subBrand: SubBrand.JoinedProduct
    let onClose: () -> Void
    
    init(brand: Brand.JoinedSubBrandsProducts, subBrand: SubBrand.JoinedProduct, onClose: @escaping () -> Void) {
        self.brand = brand
        self.subBrand = subBrand
        self.onClose = onClose
        _newSubBrandName = State(initialValue: subBrand.name ?? "")
    }


    var body: some View {
        List {
            Section {
                TextField("Name", text: $newSubBrandName)
                Button("Edit") {
                    viewModel.editSubBrand(subBrand: subBrand, name: newSubBrandName, onSuccess: {
                        print("Success!")
                    })
                }
                .disabled(!validateStringLength(str: newSubBrandName, type: .normal) || subBrand.name == newSubBrandName)
            } header: {
                Text("Name")
            }

            Section {
                ForEach(brand.subBrands.filter { $0.name != nil }, id: \.self) { subBrand in
                    Button(action: {
                        viewModel.mergeTo = subBrand
                    }) {
                        if let name = subBrand.name {
                            Text(name)
                        }
                    }
                }
            } header: {
                Text("Merge to another sub-brand")
            }
        }
        .navigationTitle("Edit \(subBrand.name ?? "")")
        .navigationBarItems(trailing: Button(action: {
            onClose()
        }) {
            Text("Cancel").bold()
        })
        .confirmationDialog("Merge Sub-brands Confirmation",
                            isPresented: $viewModel.showMergeSubBrandsConfirmation
        ) {
            if let mergeTo = viewModel.mergeTo {
                Button("Merge \(subBrand.name ?? "") to \(mergeTo.name ?? "default sub-brand")", role: .destructive, action: {
                    viewModel.mergeToSubBrand()
                })
            }
        }
    }
}

extension EditSubBrandSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var showMergeSubBrandsConfirmation = false
        @Published var mergeTo: SubBrand.JoinedProduct? {
            didSet {
                if oldValue != nil {
                    showMergeSubBrandsConfirmation = true
                } else {
                    showMergeSubBrandsConfirmation = false
                }
            }
        }

        func mergeToSubBrand() {
            DispatchQueue.main.async {
                self.mergeTo = nil
            }
        }

        func editSubBrand(subBrand: SubBrand.JoinedProduct, name: String, onSuccess: @escaping () -> Void) {
            Task {
                switch await repository.subBrand.update(updateRequest: SubBrand.UpdateRequest(id: subBrand.id, name: name)) {
                case .success():
                    onSuccess()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
