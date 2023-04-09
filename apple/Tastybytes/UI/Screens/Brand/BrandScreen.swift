import CachedAsyncImage
import SwiftUI

struct BrandScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand))
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
            RouteLink(to: .product(productJoined)) {
              ProductItemView(product: productJoined)
                .padding(2)
                .contextMenu {
                  Button(
                    action: { router.openSheet(.duplicateProduct(
                      mode: profileManager.hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                      product: productJoined
                    )) },
                    label: {
                      if profileManager.hasPermission(.canMergeProducts) {
                        Label("Merge to...", systemImage: "doc.on.doc")
                      } else {
                        Label("Mark as duplicate", systemImage: "doc.on.doc")
                      }
                    }
                  )

                  if profileManager.hasPermission(.canDeleteProducts) {
                    Button(role: .destructive, action: { viewModel.productToDelete = product }, label: {
                      Label("Delete", systemImage: "trash.fill")
                        .foregroundColor(.red)
                    })
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
                Button(action: {
                  router.openSheet(.editSubBrand(brand: viewModel.brand, subBrand: subBrand, onUpdate: {
                    Task { await viewModel.refresh() }
                  }))
                }, label: {
                  Label("Edit", systemImage: "pencil")
                })
              }

              if subBrand.isVerified {
                Button(action: { viewModel.toUnverifySubBrand = subBrand }, label: {
                  Label("Verified", systemImage: "checkmark.circle")
                })
              } else if profileManager.hasPermission(.canVerify) {
                Button(action: { viewModel.verifySubBrand(subBrand, isVerified: true) }, label: {
                  Label("Verify", systemImage: "checkmark")
                })
              } else {
                Label("Not verified", systemImage: "x.circle")
              }

              ReportButton(entity: .subBrand(viewModel.brand, subBrand))

              if profileManager.hasPermission(.canDeleteBrands) {
                Button(role: .destructive, action: { viewModel.toDeleteSubBrand = subBrand }, label: {
                  Label("Delete", systemImage: "trash.fill")
                })
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
    }
    .toolbar {
      toolbarContent
    }
    .confirmationDialog("Unverify Sub-brand",
                        isPresented: $viewModel.showSubBrandUnverificationConfirmation,
                        presenting: viewModel.toUnverifySubBrand)
    { presenting in
      Button("Unverify \(presenting.name ?? "default") sub-brand", action: {
        viewModel.verifySubBrand(presenting, isVerified: false)
        hapticManager.trigger(.notification(.success))
      })
    }
    .confirmationDialog("Unverify Brand",
                        isPresented: $viewModel.showBrandUnverificationConfirmation,
                        presenting: viewModel.brand)
    { presenting in
      Button("Unverify \(presenting.name) brand", action: {
        viewModel.verifyBrand(isVerified: false)
        hapticManager.trigger(.notification(.success))
      })
    }
    .confirmationDialog("Delete Sub-brand",
                        isPresented: $viewModel.showDeleteSubBrandConfirmation,
                        presenting: viewModel.toDeleteSubBrand)
    { presenting in
      Button(
        "Delete \(presenting.name ?? "default sub-brand") and all related products",
        role: .destructive,
        action: {
          viewModel.deleteSubBrand()
          hapticManager.trigger(.notification(.success))
        }
      )
    }
    .confirmationDialog("Delete Brand Confirmation",
                        isPresented: $viewModel.showDeleteBrandConfirmationDialog,
                        presenting: viewModel.brand)
    { presenting in
      Button("Delete \(presenting.name) Brand", role: .destructive, action: {
        viewModel.deleteBrand(onDelete: {
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
        Button(action: { router.openSheet(.addProductToBrand(brand: viewModel.brand, onCreate: { product in
          router.navigate(to: .product(product), resetStack: false)
        })) }, label: {
          Label("Add Product", systemImage: "plus")
        })
      }

      Divider()

      if profileManager.hasPermission(.canEditBrands) {
        Button(action: { router.openSheet(.editBrand(brand: viewModel.brand, onUpdate: {
          Task { await viewModel.refresh() }
        })) }, label: {
          Label("Edit", systemImage: "pencil")
        })
      }

      if viewModel.brand.isVerified {
        Button(action: { viewModel.showBrandUnverificationConfirmation = true }, label: {
          Label("Verified", systemImage: "checkmark.circle")
        })
      } else if profileManager.hasPermission(.canVerify) {
        Button(action: { viewModel.verifyBrand(isVerified: true) }, label: {
          Label("Verify", systemImage: "checkmark")
        })
      } else {
        Label("Not verified", systemImage: "x.circle")
      }

      ReportButton(entity: .brand(viewModel.brand))

      if profileManager.hasPermission(.canDeleteBrands) {
        Button(role: .destructive, action: { viewModel.showDeleteBrandConfirmationDialog.toggle() }, label: {
          Label("Delete", systemImage: "trash.fill")
        })
        .disabled(viewModel.brand.isVerified)
      }
    } label: {
      Label("Options menu", systemImage: "ellipsis")
        .labelStyle(.iconOnly)
    }
  }
}
