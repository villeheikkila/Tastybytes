import CachedAsyncImage
import SwiftUI

struct CompanyScreenView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel = ViewModel()

  let company: Company

  var body: some View {
    List {
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
      }
      productList
    }
    .navigationTitle(company.name)
    .navigationBarItems(trailing: navigationBarMenu)
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editSuggestionCompany:
          companyEditSuggestionSheet
        case .editCompany:
          companyEditSheet
        case .editBrand:
          if let editBrand = viewModel.editBrand {
            EditBrandSheetView(brand: editBrand, brandOwner: company) {
              viewModel.refreshData(companyId: company.id)
            }
          }
        case .mergeProduct:
          if let productToMerge = viewModel.productToMerge {
            MergeSheetView(productToMerge: productToMerge)
          }
        }
      }
    }
    .confirmationDialog("Delete Brand Confirmation",
                        isPresented: $viewModel.showDeleteBrandConfirmationDialog,
                        presenting: viewModel.brandToDelete) { presenting in
      Button("Delete \(presenting.name) brand", role: .destructive, action: { viewModel.deleteBrand(presenting) })
    }
    .confirmationDialog("Delete Company Confirmation",
                        isPresented: $viewModel.showDeleteCompanyConfirmationDialog,
                        presenting: company) { presenting in
      Button("Delete \(presenting.name) Company", role: .destructive, action: {
        viewModel.deleteCompany(company, onDelete: {
          router.reset()
        })
      })
    }
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: viewModel.productToDelete) { presenting in
      Button(
        "Delete \(presenting.name) Product",
        role: .destructive,
        action: {
          viewModel.deleteProduct()
        }
      )
    }
    .task {
      viewModel.refreshData(companyId: company.id)
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.company(id: company.id).url)

      if profileManager.hasPermission(.canEditCompanies) {
        Button(action: {
          viewModel.setActiveSheet(.editCompany)
        }) {
          Label("Edit", systemImage: "pencil")
        }
      } else {
        Button(action: {
          viewModel.setActiveSheet(.editSuggestionCompany)
        }) {
          Label("Edit Suggestion", systemImage: "pencil")
        }
      }

      Divider()

      if profileManager.hasPermission(.canDeleteCompanies) {
        Button(action: {
          viewModel.showDeleteCompanyConfirmationDialog.toggle()
        }) {
          Label("Delete", systemImage: "trash.fill")
        }
        .disabled(company.isVerified)
      }
    } label: {
      Image(systemName: "ellipsis")
    }
  }

  @ViewBuilder
  private var productList: some View {
    if let companyJoined = viewModel.companyJoined {
      ForEach(companyJoined.brands, id: \.id) { brand in
        Section {
          ForEach(brand.subBrands, id: \.id) {
            subBrand in
            ForEach(subBrand.products, id: \.id) {
              product in
              NavigationLink(value: Route.product(Product
                  .Joined(company: company, product: product, subBrand: subBrand, brand: brand))) {
                HStack {
                  Text(joinOptionalStrings([brand.name, subBrand.name, product.name]))
                    .lineLimit(nil)
                  Spacer()
                }
                .contextMenu {
                  if profileManager.hasPermission(.canMergeProducts) {
                    Button(action: {
                      viewModel.productToMerge = product
                    }) {
                      Text("Merge product to...")
                    }
                  }

                  if profileManager.hasPermission(.canDeleteProducts) {
                    Button(action: {
                      viewModel.productToDelete = product
                    }) {
                      Label("Delete", systemImage: "trash.fill")
                        .foregroundColor(.red)
                    }
                    .disabled(product.isVerified)
                  }
                }
              }
            }
          }
        } header: {
          HStack {
            Text("\(brand.name) (\(brand.getNumberOfProducts()))")
            Spacer()
            Menu {
              if profileManager.hasPermission(.canEditBrands) {
                Button(action: {
                  viewModel.editBrand = brand
                  viewModel.setActiveSheet(.editBrand)
                }) {
                  Label("Edit", systemImage: "pencil")
                }
              }

              if profileManager.hasPermission(.canDeleteBrands) {
                Button(action: {
                  viewModel.brandToDelete = brand
                }) {
                  Label("Delete", systemImage: "trash.fill")
                }
                .disabled(brand.isVerified)
              }
            } label: {
              Image(systemName: "ellipsis")
            }
          }
        }
        .headerProminence(.increased)
      }
    }
  }

  private var companyEditSuggestionSheet: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newCompanyNameSuggestion)
        Button("Send") {
          viewModel.sendCompanyEditSuggestion()
        }
        .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
      } header: {
        Text("What should the company be called?")
      }
    }
    .navigationTitle("Edit suggestion")
  }

  private var companyEditSheet: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newCompanyNameSuggestion)
        Button("Edit") {
          viewModel.editCompany()
        }
        .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
      } header: {
        Text("Company name")
      }
    }
    .navigationTitle("Edit Company")
  }

  private var companyHeader: some View {
    HStack(spacing: 10) {
      if let logoUrl = company.getLogoUrl() {
        CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 52, height: 52)
        } placeholder: {
          Image(systemName: "photo")
        }
      }
      Spacer()
    }
  }
}

extension CompanyScreenView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case editSuggestionCompany
    case editCompany
    case editBrand
    case mergeProduct
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CompanyScreenView")
    @Published var companyJoined: Company.Joined?
    @Published var summary: Summary?
    @Published var activeSheet: Sheet?
    @Published var newCompanyNameSuggestion = ""
    @Published var editBrand: Brand.JoinedSubBrandsProducts?
    @Published var productToMerge: Product.JoinedCategory? {
      didSet {
        setActiveSheet(.mergeProduct)
      }
    }

    @Published var productToDelete: Product.JoinedCategory? {
      didSet {
        showDeleteProductConfirmationDialog = true
      }
    }

    @Published var showDeleteProductConfirmationDialog = false
    @Published var brandToDelete: Brand.JoinedSubBrandsProducts? {
      didSet {
        showDeleteBrandConfirmationDialog = true
      }
    }

    @Published var showDeleteBrandConfirmationDialog = false
    @Published var showDeleteCompanyConfirmationDialog = false

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func sendCompanyEditSuggestion() {}

    func editCompany() {
      if let companyJoined {
        Task {
          switch await repository.company
            .update(updateRequest: Company.UpdateRequest(id: companyJoined.id, name: newCompanyNameSuggestion))
          {
          case let .success(updatedCompany):
            withAnimation {
              self.companyJoined = updatedCompany
            }
            self.activeSheet = nil
          case let .failure(error):
            logger.error("failed to edit company \(companyJoined.id): \(error.localizedDescription)")
          }
        }
      }
    }

    func refreshData(companyId: Int) {
      Task {
        switch await repository.company.getJoinedById(id: companyId) {
        case let .success(company):
          self.companyJoined = company
          self.newCompanyNameSuggestion = company.name
        case let .failure(error):
          logger.error("failed to refresh data for company '\(companyId)': \(error.localizedDescription)")
        }
      }

      Task {
        switch await repository.company.getSummaryById(id: companyId) {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          logger.error("failed to load summary for company '\(companyId)' : \(error.localizedDescription)")
        }
      }
    }

    func deleteCompany(_ company: Company, onDelete: @escaping () -> Void) {
      Task {
        switch await repository.company.delete(id: company.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger.error("failed to delete company '\(company.id)': \(error.localizedDescription)")
        }
      }
    }

    func deleteProduct() {
      if let productToDelete, let companyJoined {
        Task {
          switch await repository.product.delete(id: productToDelete.id) {
          case .success:
            refreshData(companyId: companyJoined.id)
            self.productToDelete = nil
          case let .failure(error):
            logger.error("failed to delete product '\(productToDelete.id)': \(error.localizedDescription)")
          }
        }
      }
    }

    func deleteBrand(_ brand: Brand.JoinedSubBrandsProducts) {
      Task {
        switch await repository.brand.delete(id: brand.id) {
        case .success:
          // TODO: Do not refetch the company on deletion
          if let companyJoined {
            switch await repository.company.getJoinedById(id: companyJoined.id) {
            case let .success(company):
              refreshData(companyId: company.id)
            case let .failure(error):
              logger.error("failed to load company \(brand.id) after deleting a brand: \(error.localizedDescription)")
            }
          }
        case let .failure(error):
          logger.error("failed to delete brand '\(brand.id)': \(error.localizedDescription)")
        }
      }
    }
  }
}
