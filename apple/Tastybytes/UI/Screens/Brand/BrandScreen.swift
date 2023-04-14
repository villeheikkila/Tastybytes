import CachedAsyncImage
import SwiftUI

struct BrandScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany, refreshOnLoad: Bool = false) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand, refreshOnLoad: refreshOnLoad))
  }

  var body: some View {
    List {
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      ForEach(viewModel.sortedSubBrands) { subBrand in
        Section {
          ForEach(subBrand.products) { product in
            let productJoined = Product.Joined(
              product: product,
              subBrand: subBrand,
              brand: viewModel.brand
            )
            RouterLink(screen: .product(productJoined)) {
              ProductItemView(product: productJoined)
                .padding(2)
                .contextMenu {
                  RouterLink(sheet: .duplicateProduct(
                    mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                    product: productJoined
                  ), label: {
                    if profileManager.hasPermission(.canMergeProducts) {
                      Label("Merge to...", systemImage: "doc.on.doc")
                    } else {
                      Label("Mark as duplicate", systemImage: "doc.on.doc")
                    }
                  })

                  if profileManager.hasPermission(.canDeleteProducts) {
                    Button(
                      "Delete",
                      systemImage: "trash.fill",
                      role: .destructive,
                      action: { viewModel.productToDelete = product }
                    ).foregroundColor(.red)
                      .disabled(product.isVerified)
                  }
                }
            }
          }
        } header: {
          HStack {
            if let name = subBrand.name {
              Text(name)
            }
            Spacer()
            Menu {
              if profileManager.hasPermission(.canEditBrands) {
                RouterLink(
                  "Edit",
                  systemImage: "pencil",
                  sheet: .editSubBrand(brand: viewModel.brand, subBrand: subBrand, onUpdate: {
                    await viewModel.refresh()
                  })
                )
              }

              VerificationButton(isVerified: subBrand.isVerified, verify: {
                await viewModel.verifySubBrand(subBrand, isVerified: true)
              }, unverify: {
                viewModel.toUnverifySubBrand = subBrand
              })

              ReportButton(entity: .subBrand(viewModel.brand, subBrand))

              if profileManager.hasPermission(.canDeleteBrands) {
                Button("Delete", systemImage: "trash.fill", role: .destructive, action: { viewModel.toDeleteSubBrand = subBrand })
                  .disabled(subBrand.isVerified)
              }
            } label: {
              Label("Options menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .frame(width: 24, height: 24)
            }
          }
        }
        .headerProminence(.increased)
      }
    }
    .listStyle(.plain)
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.refresh()
      }
    }
    .task {
      if viewModel.summary == nil {
        await viewModel.getSummary()
      }
      if viewModel.refreshOnLoad {
        await viewModel.refresh()
      }
    }
    .toolbar {
      toolbarContent
    }
    .confirmationDialog("Unverify Sub-brand",
                        isPresented: $viewModel.showSubBrandUnverificationConfirmation,
                        presenting: viewModel.toUnverifySubBrand)
    { presenting in
      ProgressButton("Unverify \(presenting.name ?? "default") sub-brand", action: {
        await viewModel.verifySubBrand(presenting, isVerified: false)
        hapticManager.trigger(.notification(.success))
      })
    }
    .confirmationDialog("Unverify Brand",
                        isPresented: $viewModel.showBrandUnverificationConfirmation,
                        presenting: viewModel.brand)
    { presenting in
      ProgressButton("Unverify \(presenting.name) brand", action: {
        await viewModel.verifyBrand(isVerified: false)
        hapticManager.trigger(.notification(.success))
      })
    }
    .confirmationDialog("Are you sure you want to delete sub-brand and all related products?",
                        isPresented: $viewModel.showDeleteSubBrandConfirmation,
                        titleVisibility: .visible,
                        presenting: viewModel.toDeleteSubBrand)
    { presenting in
      ProgressButton(
        "Delete \(presenting.name ?? "default sub-brand")",
        role: .destructive,
        action: {
          await viewModel.deleteSubBrand()
          hapticManager.trigger(.notification(.success))
        }
      )
    }
    .confirmationDialog("Are you sure you want to delete brand and all related sub-brands and products?",
                        isPresented: $viewModel.showDeleteBrandConfirmationDialog,
                        titleVisibility: .visible,
                        presenting: viewModel.brand)
    { presenting in
      ProgressButton("Delete \(presenting.name)", role: .destructive, action: {
        await viewModel.deleteBrand(onDelete: {
          router.reset()
          hapticManager.trigger(.notification(.success))
        })
      })
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .principal) {
      HStack(alignment: .center, spacing: 18) {
        if let logoUrl = viewModel.brand.logoUrl {
          CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 32, height: 32)
              .accessibility(hidden: true)
          } placeholder: {
            ProgressView()
          }
        }
        Text(viewModel.brand.name)
          .font(.headline)
      }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      navigationBarMenu
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.brand(id: viewModel.brand.id).url)

      if profileManager.hasPermission(.canCreateProducts) {
        RouterLink("Add Product", systemImage: "plus", sheet: .addProductToBrand(brand: viewModel.brand, onCreate: { product in
          router.navigate(screen: .product(product))
        }))
      }

      Divider()

      if profileManager.hasPermission(.canEditBrands) {
        RouterLink("Edit", systemImage: "pencil", sheet: .editBrand(brand: viewModel.brand, onUpdate: {
          await viewModel.refresh()
        }))
      }

      VerificationButton(isVerified: viewModel.brand.isVerified, verify: {
        await viewModel.verifyBrand(isVerified: true)
      }, unverify: {
        viewModel.showBrandUnverificationConfirmation = true
      })

      ReportButton(entity: .brand(viewModel.brand))

      if profileManager.hasPermission(.canDeleteBrands) {
        Button(
          "Delete",
          systemImage: "trash.fill",
          role: .destructive,
          action: { viewModel.showDeleteBrandConfirmationDialog = true }
        )
        .disabled(viewModel.brand.isVerified)
      }
    } label: {
      Label("Options menu", systemImage: "ellipsis")
        .labelStyle(.iconOnly)
    }
  }
}
