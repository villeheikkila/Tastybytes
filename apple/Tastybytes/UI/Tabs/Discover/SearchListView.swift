import SwiftUI

struct SearchListView: View {
  @StateObject private var viewModel: ViewModel
  @State private var scrollProxy: ScrollViewProxy?
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding private var scrollToTop: Int

  init(_ client: Client, scrollToTop: Binding<Int>) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _scrollToTop = scrollToTop
  }

  var body: some View {
    ScrollViewReader { proxy in
      List {
        if viewModel.currentScopeIsEmpty {
          searchScopeList
        }
        switch viewModel.searchScope {
        case .products:
          productResults
        case .companies:
          companyResults
        case .users:
          profileResults
        case .locations:
          locationResults
        }
      }
      .onAppear {
        scrollProxy = proxy
      }
      .listStyle(.plain)
      .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                  prompt: viewModel.searchScope.prompt)
      .disableAutocorrection(true)
      .searchScopes($viewModel.searchScope) {
        ForEach(SearchScope.allCases) { scope in
          Text(scope.label).tag(scope)
        }
      }
      .onSubmit(of: .search) {
        Task { await viewModel.search() }
      }
      .onChange(of: viewModel.searchScope, perform: { _ in
        Task { await viewModel.search() }
        viewModel.barcode = nil
      })
      .onChange(of: viewModel.searchTerm, perform: { term in
        if term.isEmpty {
          Task {
            await viewModel.resetSearch()
          }
        }
      })
      .onReceive(
        viewModel.$searchTerm.debounce(for: 0.2, scheduler: RunLoop.main)
      ) { _ in
        Task { await viewModel.search() }
      }
    }
    .navigationTitle("Discover")
    .toolbar {
      toolbarContent
    }
    .confirmationDialog(
      "Add barcode confirmation",
      isPresented: $viewModel.showAddBarcodeConfirmation,
      presenting: viewModel.addBarcodeTo
    ) { presenting in
      ProgressButton(
        "Add barcode to \(presenting.getDisplayName(.fullName))",
        action: {
          await viewModel.addBarcodeToProduct(onComplete: {
            toastManager.toggle(.success("Barcode added!"))
          })
        }
      )
    }
    .overlay {
      if viewModel.searchScope == .products, viewModel.productFilter != nil {
        if let productFilter = viewModel.productFilter {
          ProductFilterOverlayView(filters: productFilter, onReset: {
            viewModel.productFilter = nil
          })
        }
      }
    }
    .onChange(of: scrollToTop) { _ in
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
  }

  private var searchScopeList: some View {
    Section {
      Button(action: { viewModel.searchScope = .products }, label: {
        Label("Products", systemImage: "grid").bold()
          .listRowSeparator(.visible)
      })
      Button(action: { viewModel.searchScope = .companies }, label: {
        Label("Companies", systemImage: "network").bold()
          .listRowSeparator(.visible)
      })
      Button(action: { viewModel.searchScope = .users }, label: {
        Label("Users", systemImage: "person").bold()
          .listRowSeparator(.visible)
      })
      Button(action: { viewModel.searchScope = .locations }, label: {
        Label("Locations", systemImage: "location").bold()
          .listRowSeparator(.visible)
      })
    } header: {
      Text("Search")
    }.headerProminence(.increased)
  }

  private var profileResults: some View {
    ForEach(viewModel.profiles) { profile in
      RouteLink(to: .profile(profile)) {
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
    ForEach(viewModel.companies) { company in
      RouteLink(to: .company(company)) {
        Text(company.name)
      }
      .id(company.id)
    }
  }

  private var locationResults: some View {
    ForEach(viewModel.locations) { location in
      RouteLink(to: .location(location)) {
        Text(location.name)
      }
      .id(location.id)
    }
  }

  @ViewBuilder private var productResults: some View {
    if viewModel.barcode != nil {
      Section {
        Text(
          """
          \(viewModel.products.isEmpty ? "No results were found" : "If none of the results match"),\
          you can assign the barcode to a product by searching again \
          with the name or by creating a new product.
          """
        )
        Button(action: { viewModel.resetBarcode() }, label: {
          Text("Dismiss barcode")
        })
      }
    }

    if viewModel.currentScopeIsEmpty {
      Section {
        RouteLink(to: .productFeed(.trending)) {
          Label(Product.FeedType.trending.label, systemImage: "chart.line.uptrend.xyaxis").bold()
            .listRowSeparator(.visible)
        }

        RouteLink(to: .productFeed(.topRated)) {
          Label(Product.FeedType.topRated.label, systemImage: "line.horizontal.star.fill.line.horizontal").bold()
            .listRowSeparator(.visible)
        }

        RouteLink(to: .productFeed(.latest)) {
          Label(Product.FeedType.latest.label, systemImage: "bolt.horizontal.circle").bold()
            .listRowSeparator(.visible)
        }
      } header: {
        Text("Feeds")
      }.headerProminence(.increased)
    } else {
      ForEach(viewModel.products) { product in
        ProductItemView(product: product, extras: [.checkInCheck, .rating])
          .swipeActions {
            Button(action: { router.openSheet(.newCheckIn(product, onCreation: { checkIn in
              router.navigate(to: .checkIn(checkIn), resetStack: false)
            })) }, label: {
              Label("Check-in", systemImage: "plus")
            }).tint(.green)
          }
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            if viewModel.barcode == nil || product.barcodes.contains(where: { $0.isBarcode(viewModel.barcode) }) {
              router.navigate(to: .product(product), resetStack: false)
            } else {
              viewModel.addBarcodeTo = product
            }
          }
          .id(product.id)
      }
    }
    if viewModel.isSearched, profileManager.hasPermission(.canCreateProducts) {
      Section {
        HStack {
          Text("Add new")
            .fontWeight(.medium)
          Spacer()
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isLink)
        .onTapGesture {
          let barcode = viewModel.barcode
          viewModel.barcode = nil
          router.navigate(to: .addProduct(barcode), resetStack: false)
        }
      } header: {
        Text("Didn't find a product you were looking for?")
      }
      .textCase(nil)
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      if viewModel.searchScope == .products {
        Button(
          action: {
            router
              .sheet = .productFilter(initialFilter: viewModel.productFilter, sections: [.category, .checkIns],
                                      onApply: { filter in
                                        viewModel.productFilter = filter
                                      })
          },
          label: {
            Label("Show filters", systemImage: "line.3.horizontal.decrease.circle")
              .labelStyle(.iconOnly)
          }
        )
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if profileManager.hasPermission(.canAddBarcodes) {
        Button(action: { router.openSheet(.barcodeScanner(onComplete: { barcode in
          Task { await viewModel.searchProductsByBardcode(barcode) }
        })) }, label: {
          Label("Scan a barcode", systemImage: "barcode.viewfinder")
            .labelStyle(.iconOnly)
        })
      }
    }
  }
}
