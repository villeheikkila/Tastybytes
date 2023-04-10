import SwiftUI

struct VerificationScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      switch viewModel.verificationType {
      case .products:
        unverifiedProducts
      case .companies:
        unverifiedCompanies
      case .brands:
        unverifiedBrands
      case .subBrands:
        unverifiedSubBrands
      }
    }
    .listStyle(.plain)
    .confirmationDialog("Delete Product Confirmation",
                        isPresented: $viewModel.showDeleteProductConfirmationDialog,
                        presenting: viewModel.deleteProduct)
    { presenting in
      Button(
        "Delete \(presenting.getDisplayName(.fullName)) Product",
        role: .destructive,
        action: { viewModel.deleteProduct(onDelete: {
          hapticManager.trigger(.notification(.success))
        })
        }
      )
    }
    .navigationBarTitle("Unverified \(viewModel.verificationType.label)")
    .toolbar {
      toolbarContent
    }
    .onChange(of: viewModel.verificationType, perform: { _ in
      Task {
        await viewModel.loadData()
      }
    })
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.loadData(refresh: true)
      }
    }
    .task {
      await viewModel.loadData()
    }
  }

  private var unverifiedCompanies: some View {
    ForEach(viewModel.companies) { company in
      RouteLink(screen: .company(company)) {
        Text(company.name)
      }
      .swipeActions {
        Button(action: { viewModel.verifyCompany(company) }, label: {
          Label("Verify", systemImage: "checkmark")
        }).tint(.green)
      }
    }
  }

  private var unverifiedSubBrands: some View {
    ForEach(viewModel.subBrands) { subBrand in
      HStack {
        Text("\(subBrand.brand.brandOwner.name): \(subBrand.brand.name): \(subBrand.name ?? "-")")
        Spacer()
      }
      .onTapGesture {
        router.fetchAndNavigateTo(viewModel.client, .brand(id: subBrand.brand.id))
      }
      .accessibilityAddTraits(.isButton)
      .swipeActions {
        Button(action: { viewModel.verifySubBrand(subBrand) }, label: {
          Label("Verify", systemImage: "checkmark")
        }).tint(.green)
      }
    }
  }

  private var unverifiedBrands: some View {
    ForEach(viewModel.brands) { brand in
      RouteLink(screen: .brand(brand)) {
        HStack {
          Text("\(brand.brandOwner.name): \(brand.name)")
          Spacer()
          Text("(\(brand.getNumberOfProducts()))")
        }
      }
      .swipeActions {
        Button(action: { viewModel.verifyBrand(brand) }, label: {
          Label("Verify", systemImage: "checkmark")
        }).tint(.green)
      }
    }
  }

  private var unverifiedProducts: some View {
    ForEach(viewModel.products) { product in
      VStack {
        if let createdBy = product.createdBy {
          HStack {
            AvatarView(avatarUrl: createdBy.avatarUrl, size: 16, id: createdBy.id)
            Text(createdBy.preferredName).font(.caption).bold()
            Spacer()
            if let createdAt = product.createdAt, let date = Date(timestamptzString: createdAt) {
              Text(date.customFormat(.relativeTime)).font(.caption).bold()
            }
          }
        }
        ProductItemView(product: product)
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(screen: .product(product))
          }
          .swipeActions {
            Button(action: { viewModel.verifyProduct(product) }, label: {
              Label("Verify", systemImage: "checkmark")
            }).tint(.green)
            Button(action: { router.navigate(sheet: .editProduct(product: product, onEdit: {
              Task {
                await viewModel.loadData(refresh: true)
              }
            })) }, label: {
              Label("Edit", systemImage: "pencil")
            }).tint(.yellow)
            Button(role: .destructive, action: { viewModel.deleteProduct = product }, label: {
              Label("Delete", systemImage: "trash")
            })
          }
      }
    }
  }

  private var toolbarContent: some ToolbarContent {
    ToolbarTitleMenu {
      ForEach(VerificationType.allCases) { type in
        Button {
          viewModel.verificationType = type
        } label: {
          Text("Unverified \(type.label)")
        }
      }
    }
  }
}
