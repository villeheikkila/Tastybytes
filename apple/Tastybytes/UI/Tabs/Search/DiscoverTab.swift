import SwiftUI

struct DiscoverTab: View {
  @StateObject private var viewModel: ViewModel
  @Binding private var resetNavigationOnTab: Tab?
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var router = Router()
  @State private var scrollProxy: ScrollViewProxy?

  private let topAnchor = "top"

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      ScrollViewReader { proxy in
        List {
          content
        }
        .onAppear {
          scrollProxy = proxy
        }
        .listStyle(.plain)
        .onChange(of: viewModel.searchScope, perform: { _ in
          viewModel.search()
          viewModel.barcode = nil
        })
        .onChange(of: viewModel.searchTerm, perform: { term in
          if term.isEmpty {
            viewModel.resetSearch()
          }
        })
        .onReceive(
          viewModel.$searchTerm.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
        ) { _ in
          viewModel.search()
        }
        .if(viewModel.searchScope == .products && viewModel.productFilter != nil, transform: { view in
          view.overlay {
            BottomOverlay {
              if let productFilter = viewModel.productFilter {
                ProductFilterOverlayView(filters: productFilter)
              }
            }
          }
        })
        .sheet(isPresented: $viewModel.showBarcodeScanner) {
          NavigationStack {
            BarcodeScannerSheetView(onComplete: { barcode in
              viewModel.searchProductsByBardcode(barcode)
            })
          }
          .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showFilters) {
          NavigationStack {
            ProductFilterSheetView(
              viewModel.client,
              initialFilter: viewModel.productFilter,
              sections: [.category, .checkIns],
              onApply: { filter in
                viewModel.productFilter = filter
                viewModel.showFilters = false
              }
            )
          }
          .presentationDetents([.medium])
        }
        .confirmationDialog(
          "Add barcode confirmation",
          isPresented: $viewModel.showAddBarcodeConfirmation,
          presenting: viewModel.addBarcodeTo
        ) { presenting in
          Button(
            "Add barcode to \(presenting.getDisplayName(.fullName))",
            action: {
              viewModel.addBarcodeToProduct(onComplete: {
                toastManager.toggle(.success("Barcode added!"))
              })
            }
          )
        }
        .searchable(text: $viewModel.searchTerm,
                    prompt: viewModel.searchScope.prompt)
        .disableAutocorrection(true)
        .searchScopes($viewModel.searchScope) {
          ForEach(SearchScope.allCases) { scope in
            Text(scope.label).tag(scope)
          }
        }
        .onSubmit(of: .search) {
          viewModel.search()
        }
        .navigationTitle("Discover")
        .toolbar {
          toolbarContent
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
          if tab == .search {
            if router.path.isEmpty {
              withAnimation {
                switch viewModel.searchScope {
                case .products:
                  if let id = viewModel.products.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                case .companies:
                  if let id = viewModel.companies.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                case .users:
                  if let id = viewModel.profiles.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                case .locations:
                  if let id = viewModel.locations.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                }
              }
            }
          } else {
            router.reset()
          }
          resetNavigationOnTab = nil
        }
      }.withRoutes(viewModel.client)
    }
    .environmentObject(router)
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.searchScope {
    case .products:
      if viewModel.products.isEmpty {
        Section {
          NavigationLink(value: Route.productFeed(.trending)) {
            Label("Trending", systemImage: "chart.line.uptrend.xyaxis").bold()
          }
          .listRowSeparator(.visible)

          NavigationLink(value: Route.productFeed(.topRated)) {
            Label("Top Rated", systemImage: "line.horizontal.star.fill.line.horizontal").bold()
          }
        } header: {
          Text("Feeds")
        }.headerProminence(.increased)
      } else {
        productResults
      }
      if viewModel.isSearched {
        if viewModel.barcode != nil {
          addBarcodeNotice
        }
        addProductNotice
      }
    case .companies:
      companyResults
    case .users:
      profileResults
    case .locations:
      locationResults
    }
  }

  @ViewBuilder
  private var overlayContent: some View {
    if let filters = viewModel.productFilter {
      HStack {
        if let category = filters.category {
          Text(category.name.label).bold()
        }
        if filters.category != nil, filters.subcategory != nil {
          Image(systemName: "arrowtriangle.forward")
            .accessibility(hidden: true)
        }
        if let subcategory = filters.subcategory {
          Text(subcategory.name).bold()
        }
      }
      if filters.onlyNonCheckedIn {
        Text("Show only products you haven't tried").fontWeight(.medium)
      }
    }
  }

  private var profileResults: some View {
    ForEach(viewModel.profiles, id: \.self) { profile in
      NavigationLink(value: Route.profile(profile)) {
        HStack(alignment: .center) {
          AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
          VStack {
            HStack {
              Text(profile.preferredName)
              Spacer()
            }
          }
        }
      }
      .id(profile.id)
    }
  }

  private var companyResults: some View {
    ForEach(viewModel.companies, id: \.self) { company in
      NavigationLink(value: Route.company(company)) {
        Text(company.name)
      }
      .id(company.id)
    }
  }

  private var addBarcodeNotice: some View {
    Section {
      Text(
        """
        \(viewModel.products.isEmpty ? "No results were found" : "If none of the results match"),\
        you can assign the barcode to a product by searching again\
        with the name or by creating a new product.
        """
      )
      Button(action: { viewModel.resetBarcode() }, label: {
        Text("Dismiss barcode")
      })
    }
  }

  private var addProductNotice: some View {
    Section {
      NavigationLink("Add new", value: Route.addProduct(viewModel.barcode))
        .fontWeight(.medium)
        .disabled(!profileManager.hasPermission(.canCreateProducts))
    } header: {
      Text("Didn't find a product you were looking for?")
    }
    .textCase(nil)
  }

  private var locationResults: some View {
    ForEach(viewModel.locations, id: \.self) { location in
      NavigationLink(value: Route.location(location)) {
        Text(location.name)
      }
      .id(location.id)
    }
  }

  private var productResults: some View {
    ForEach(viewModel.products, id: \.id) { product in
      if viewModel.barcode == nil || product.barcodes.contains(where: { $0.isBarcode(viewModel.barcode) }) {
        ProductItemView(product: product, extras: [.checkInCheck, .rating])
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
          .id(product.id)
      } else {
        Button(action: { viewModel.addBarcodeTo = product }, label: {
          ProductItemView(product: product)
        })
        .buttonStyle(.plain)
      }
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      if viewModel.searchScope == .products {
        Button(action: { viewModel.showFilters.toggle() }, label: {
          Label("Show filters", systemImage: "line.3.horizontal.decrease.circle")
            .labelStyle(.iconOnly)
        })
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if profileManager.hasPermission(.canAddBarcodes) {
        Button(action: { viewModel.showBarcodeScanner.toggle() }, label: {
          Label("Scan a barcode", systemImage: "barcode.viewfinder")
            .labelStyle(.iconOnly)
        })
      }
    }
  }
}
