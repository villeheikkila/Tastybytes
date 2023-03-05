import SwiftUI

extension BrandScreen {
  enum Sheet: Identifiable {
    var id: Self { self }
    case editBrand
    case editSubBrand
    case duplicateProduct
    case addProduct
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BrandScreen")
    let client: Client
    @Published var brand: Brand.JoinedSubBrandsProductsCompany
    @Published var summary: Summary?
    @Published var activeSheet: Sheet?
    @Published var editBrand: Brand.JoinedSubBrandsProductsCompany?
    @Published var toUnverifySubBrand: SubBrand.JoinedProduct? {
      didSet {
        showSubBrandUnverificationConfirmation = true
      }
    }

    @Published var showSubBrandUnverificationConfirmation = false
    @Published var showBrandUnverificationConfirmation = false
    @Published var editSubBrand: SubBrand.JoinedProduct? {
      didSet {
        setActiveSheet(.editSubBrand)
      }
    }

    @Published var duplicateProduct: Product.Joined? {
      didSet {
        setActiveSheet(.duplicateProduct)
      }
    }

    @Published var showDeleteProductConfirmationDialog = false
    @Published var productToDelete: Product.JoinedCategory? {
      didSet {
        if productToDelete != nil {
          showDeleteProductConfirmationDialog = true
        }
      }
    }

    @Published var showDeleteBrandConfirmationDialog = false
    @Published var brandToDelete: Brand.JoinedSubBrandsProducts? {
      didSet {
        showDeleteBrandConfirmationDialog = true
      }
    }

    @Published var showDeleteSubBrandConfirmation = false
    @Published var toDeleteSubBrand: SubBrand.JoinedProduct? {
      didSet {
        if oldValue == nil {
          showDeleteSubBrandConfirmation = true
        } else {
          showDeleteSubBrandConfirmation = false
        }
      }
    }

    init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
      self.client = client
      self.brand = brand
    }

    var sortedSubBrands: [SubBrand.JoinedProduct] {
      brand.subBrands
        .filter { !($0.name == nil && $0.products.isEmpty) }
        .sorted { lhs, rhs -> Bool in
          switch (lhs.name, rhs.name) {
          case let (lhs?, rhs?): return lhs < rhs
          case (nil, _): return true
          case (_?, nil): return false
          }
        }
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func refresh() {
      Task {
        async let summaryPromise = client.brand.getSummaryById(id: brand.id)
        async let brandPromise = client.brand.getJoinedById(id: brand.id)

        switch await summaryPromise {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          logger
            .error("failed to load summary for brand: \(error.localizedDescription)")
        }

        switch await brandPromise {
        case let .success(brand):
          self.brand = brand
        case let .failure(error):
          logger.error("request for brand with \(self.brand.id) failed: \(error.localizedDescription)")
        }
      }
    }

    func getSummary() async {
      async let summaryPromise = client.brand.getSummaryById(id: brand.id)
      switch await summaryPromise {
      case let .success(summary):
        self.summary = summary
      case let .failure(error):
        logger
          .error("failed to load summary for brand: \(error.localizedDescription)")
      }
    }

    func verifyBrand(isVerified: Bool) {
      Task {
        switch await client.brand.verification(id: brand.id, isVerified: isVerified) {
        case .success:
          brand = Brand.JoinedSubBrandsProductsCompany(
            id: brand.id,
            name: brand.name,
            isVerified: isVerified,
            brandOwner: brand.brandOwner,
            subBrands: brand.subBrands
          )
        case let .failure(error):
          logger
            .error("failed to verify brand by id '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func verifySubBrand(_ subBrand: SubBrand.JoinedProduct, isVerified: Bool) {
      Task {
        switch await client.subBrand.verification(id: subBrand.id, isVerified: isVerified) {
        case .success:
          refresh()
          logger
            .info("sub-brand succesfully verified")
        case let .failure(error):
          logger
            .error("failed to verify brand by id '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func deleteBrand(onDelete: @escaping () -> Void) {
      Task {
        switch await client.brand.delete(id: brand.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger
            .error("failed to delete brand by id '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func deleteSubBrand() {
      if let toDeleteSubBrand {
        Task {
          switch await client.subBrand.delete(id: toDeleteSubBrand.id) {
          case .success:
            refresh()
            logger.info("succesfully deleted sub-brand")
          case let .failure(error):
            logger.error("failed to delete brand '\(toDeleteSubBrand.id)': \(error.localizedDescription)")
          }
        }
      }
    }
  }
}
