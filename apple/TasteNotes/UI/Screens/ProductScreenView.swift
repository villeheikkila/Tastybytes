import SwiftUI

struct ProductScreenView: View {
  let product: Product.Joined
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject var profileManager: ProfileManager
  @State private var scrollToTop: Int = 0

  var body: some View {
    InfiniteScrollView(
      data: $viewModel.checkIns,
      isLoading: $viewModel.isLoading, scrollToTop: $scrollToTop,
      loadMore: { viewModel.fetchMoreCheckIns(productId: product.id) },
      refresh: { viewModel.refresh(productId: product.id) },
      content: {
        CheckInCardView(checkIn: $0,
                        loadedFrom: .product,
                        onDelete: { checkIn in viewModel.deleteCheckIn(checkIn) },
                        onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn) })
      },
      header: {
        productInfo
        productSummary
      }
    )
    .task {
      viewModel.loadProductSummary(product)
    }
    .navigationBarItems(
      trailing: Button(action: {
        viewModel.setActiveSheet(.checkIn)
      }) {
        Text("Check-in!")
          .bold()
      }.disabled(!profileManager.hasPermission(.canCreateCheckIns))
    )
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .checkIn:
          CheckInSheetView(product: product, onCreation: {
            viewModel.appendNewCheckIn(newCheckIn: $0)
          })
        case .editSuggestion:
          ProductSheetView(mode: .editSuggestion, initialProduct: product)
        case .editProduct:
          ProductSheetView(mode: .edit, initialProduct: product, onEdit: {
            viewModel.activeSheet = nil
          })
        }
      }
    }
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog) {
      Button("Delete Product", role: .destructive, action: { viewModel.deleteProduct(product)
      })
    }
  }

  var productInfo: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(product.getDisplayName(.fullName))
          .font(.system(size: 18, weight: .bold, design: .default))
          .foregroundColor(.primary)

        HStack {
          NavigationLink(value: Route.company(product.subBrand.brand.brandOwner)) {
            Text(product.getDisplayName(.brandOwner))
              .font(.system(size: 16, weight: .bold, design: .default))
              .foregroundColor(.secondary)
          }
        }

        HStack {
          CategoryNameView(category: product.category)

          ForEach(product.subcategories, id: \.id) { subcategory in
            ChipView(title: subcategory.name, cornerRadius: 5)
          }
        }
      }.padding([.leading, .trailing], 10)
      Spacer()
    }
    .contextMenu {
      ShareLink("Share", item: createLinkToScreen(.product(id: product.id)))

      if profileManager.hasPermission(.canEditCompanies) {
        Button(action: {
          viewModel.setActiveSheet(.editProduct)
        }) {
          Label("Edit", systemImage: "pencil")
        }
      } else {
        Button(action: {
          viewModel.setActiveSheet(.editSuggestion)
        }) {
          Label("Edit Suggestion", systemImage: "pencil")
        }
      }

      if profileManager.hasPermission(.canDeleteProducts) {
        Divider()
        Button(action: {
          viewModel.showDeleteConfirmation()
        }) {
          Label("Delete", systemImage: "trash.fill")
        }
      }
    }
  }

  @ViewBuilder
  var productSummary: some View {
    if let productSummary = viewModel.productSummary, productSummary.averageRating != nil {
      Grid(alignment: .leading) {
        GridRow {
          Text("")
          Spacer()
          Text("Check-ins")
            .font(.system(size: 10, weight: .bold, design: .default))
          Spacer()
          Text("Rating")
            .font(.system(size: 10, weight: .bold, design: .default))
        }
        Divider()
          .gridCellUnsizedAxes(.horizontal)

        if let averageRating = productSummary.averageRating {
          GridRow {
            Text("Everyone")
              .font(.system(size: 10, weight: .bold, design: .default))
            Spacer()
            Text(String(productSummary.totalCheckIns))
              .font(.system(size: 10, weight: .medium, design: .default))
            Spacer()
            RatingView(rating: averageRating, type: .small)
          }

          Divider()
            .gridCellUnsizedAxes(.horizontal)
        }

        if let friendsAverageRating = productSummary.friendsAverageRating {
          GridRow {
            Text("Friends")
              .font(.system(size: 10, weight: .bold, design: .default))
            Spacer()
            Text(String(productSummary.friendsTotalCheckIns))
              .font(.system(size: 10, weight: .medium, design: .default))
            Spacer()
            RatingView(rating: friendsAverageRating, type: .small)
          }

          Divider()
            .gridCellUnsizedAxes(.horizontal)
        }

        if let currentUserAverageRating = productSummary.currentUserAverageRating {
          GridRow {
            Text("You")
              .font(.system(size: 10, weight: .bold, design: .default))
            Spacer()
            Text(String(productSummary.currentUserTotalCheckIns))
              .font(.system(size: 10, weight: .medium, design: .default))
            Spacer()
            RatingView(rating: currentUserAverageRating, type: .small)
          }
        }
      }
      .padding([.leading, .trailing], 10)
      .padding(.top, 5)
    }
  }
}

extension ProductScreenView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case checkIn
    case editSuggestion
    case editProduct
  }

  @MainActor class ViewModel: ObservableObject {
    @Published var checkIns = [CheckIn]()
    @Published var isLoading = false
    @Published var activeSheet: Sheet?
    @Published var productSummary: ProductSummary?
    @Published var showDeleteProductConfirmationDialog = false
    @Published var showEditSuggestionSheet = false

    let pageSize = 10
    var page = 0

    func refresh(productId: Int) {
      page = 0
      checkIns = []
      fetchMoreCheckIns(productId: productId)
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func showDeleteConfirmation() {
      showDeleteProductConfirmationDialog.toggle()
    }

    func loadProductSummary(_ product: Product.Joined) {
      Task {
        switch await repository.product.getSummaryById(id: product.id) {
        case let .success(summary):
          await MainActor.run {
            self.productSummary = summary
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func deleteCheckIn(_ checkIn: CheckIn) {
      Task {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
          self.checkIns.remove(object: checkIn)
        case let .failure(error):
          print(error)
        }
      }
    }

    func deleteProduct(_ product: Product.Joined) {
      Task {
        switch await repository.product.delete(id: product.id) {
        case .success:
          print("TODO HANDLE THIS!!")
        case let .failure(error):
          print(error)
        }
      }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
      if let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) {
        DispatchQueue.main.async {
          self.checkIns[index] = checkIn
        }
      }
    }

    func fetchMoreCheckIns(productId: Int) {
      let (from, to) = getPagination(page: page, size: pageSize)

      Task {
        await MainActor.run {
          self.isLoading = true
        }

        switch await repository.checkIn.getByProductId(id: productId, from: from, to: to) {
        case let .success(checkIns):
          await MainActor.run {
            self.checkIns.append(contentsOf: checkIns)
            self.page += 1
            self.isLoading = false
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func appendNewCheckIn(newCheckIn: CheckIn) {
      checkIns.insert(newCheckIn, at: 0)
    }
  }
}
