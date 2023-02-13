import SwiftUI

struct BrandSheetView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let brandOwner: Company
  let onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void

  init(
    _ client: Client,
    brandOwner: Company,
    mode: Mode,
    onSelect: @escaping (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, mode: mode))
    self.brandOwner = brandOwner
    self.onSelect = onSelect
  }

  var body: some View {
    List {
      if viewModel.mode == .select {
        ForEach(viewModel.brandsWithSubBrands, id: \.self) { brand in
          Button(action: {
            onSelect(brand, false)
          }) {
            Text(brand.name)
          }
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section {
          TextField("Name", text: $viewModel.brandName)
          Button("Create") {
            viewModel.createNewBrand(brandOwner) {
              brand in onSelect(brand, true)
            }
          }
          .disabled(!validateStringLength(str: viewModel.brandName, type: .normal))
        } header: {
          Text("Add new brand for \(brandOwner.name)")
        }
      }
    }
    .navigationTitle("Add brand name")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Cancel").bold()
    })
    .task {
      viewModel.loadBrands(brandOwner)
    }
  }
}

extension BrandSheetView {
  enum Mode {
    case select, new
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BrandSheetView")
    let client: Client
    @Published var searchText = ""
    @Published var brandsWithSubBrands = [Brand.JoinedSubBrands]()
    @Published var brandName = ""
    let mode: Mode

    init(_ client: Client, mode: Mode) {
      self.client = client
      self.mode = mode
    }

    func loadBrands(_ brandOwner: Company) {
      Task {
        switch await client.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id) {
        case let .success(brandsWithSubBrands):
          self.brandsWithSubBrands = brandsWithSubBrands
        case let .failure(error):
          logger.error("failed to load brands for \(brandOwner.id): \(error.localizedDescription)")
        }
      }
    }

    func createNewBrand(_ brandOwner: Company, _ onCreation: @escaping (_ brand: Brand.JoinedSubBrands) -> Void) {
      Task {
        switch await client.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id)) {
        case let .success(brandWithSubBrands):
          onCreation(brandWithSubBrands)
        case let .failure(error):
          logger
            .error(
              """
              failed to create new brand for \(brandOwner.id)\
                 with name \(self.brandName): \(error.localizedDescription)
              """
            )
        }
      }
    }
  }
}
