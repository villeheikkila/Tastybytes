import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct ActivityTabView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var toastManager: ToastManager
  @StateObject private var router = Router()
  @State private var scrollToTop: Int = 0
  @Binding var resetNavigationOnTab: Tab?
  private let topAnchor = "top"
  @State private var scrollProxy: ScrollViewProxy?

  var body: some View {
    NavigationStack(path: $router.path) {
      ScrollViewReader { proxy in
        ZStack(alignment: .top) {
          ScrollView {
            Rectangle()
              .frame(height: 0)
              .id(topAnchor)
            LazyVStack(spacing: 8) {
              checkInsList
            }
            if viewModel.isLoading {
              ProgressView()
                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            }
          }
          .onAppear {
            scrollProxy = proxy
          }
          .confirmationDialog("Delete Check-in Confirmation",
                              isPresented: $viewModel.showDeleteCheckInConfirmationDialog,
                              presenting: viewModel.showDeleteConfirmationFor) { presenting in
            Button(
              "Delete the check-in for \(presenting.product.getDisplayName(.fullName))",
              role: .destructive,
              action: {
                viewModel.deleteCheckIn(checkIn: presenting)
              }
            )
          }

          .onChange(of: scrollToTop, perform: { _ in
            withAnimation {
              scrollProxy?.scrollTo(topAnchor, anchor: .top)
            }
          })
          .refreshable {
            viewModel.refresh()
          }
          .task {
            viewModel.fetchActivityFeedItems(onComplete: {
              if splashScreenManager.state != .finished {
                splashScreenManager.dismiss()
              }
            })
          }
        }
      }
      .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
        if tab == .activity {
          if router.path.isEmpty {
            scrollToTop += 1
          } else {
            router.reset()
          }
          resetNavigationOnTab = nil
        }
      }
      .navigationTitle("Activity")
      .toolbar {
        toolbarContent
      }
      .onAppear {
        router.reset()
      }
      .onOpenURL { url in
        if let detailPage = url.detailPage {
          router.fetchAndNavigateTo(detailPage)
        }
      }
      .sheet(item: $viewModel.editCheckIn) { checkIn in
        NavigationStack {
          CheckInSheetView(checkIn: checkIn, onUpdate: {
            updatedCheckIn in viewModel.onCheckInUpdate(updatedCheckIn)
          })
        }
      }
      .withRoutes()
    }
    .environmentObject(router)
  }

  @ViewBuilder
  private var checkInsList: some View {
    ForEach(viewModel.checkIns, id: \.self) { checkIn in
      NewCheckInCardView(checkIn: checkIn,
                         loadedFrom: .activity(profileManager.getProfile()))
        .contextMenu {
          ShareLink("Share", item: createLinkToScreen(.checkIn(id: checkIn.id)))
          Divider()
          if checkIn.profile.id == profileManager.getId() {
            Button(action: {
              viewModel.editCheckIn = checkIn
            }) {
              Label("Edit", systemImage: "pencil")
            }

            Button(action: {
              viewModel.showDeleteConfirmationFor = checkIn
            }) {
              Label("Delete", systemImage: "trash.fill")
            }
          }
        }
        .onAppear {
          if checkIn == viewModel.checkIns.last, viewModel.isLoading != true {
            viewModel.fetchActivityFeedItems()
          }
        }
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      NavigationLink(value: Route.currentUserFriends) {
        Image(systemName: "person.2").imageScale(.large)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      NavigationLink(value: Route.settings) {
        Image(systemName: "gear").imageScale(.large)
      }
    }
  }
}

extension ActivityTabView {
  @MainActor class ViewModel: ObservableObject {
    @Published var showDeleteConfirmationFor: CheckIn? {
      didSet {
        showDeleteCheckInConfirmationDialog = true
      }
    }

    @Published var editCheckIn: CheckIn?

    @Published var showDeleteCheckInConfirmationDialog = false
    @Published var checkIns = [CheckIn]()
    @Published var isLoading = false
    private let pageSize = 10
    private var page = 0

    func refresh() {
      DispatchQueue.main.async {
        self.page = 0
        self.checkIns = [CheckIn]()
        self.fetchActivityFeedItems()
      }
    }

    func deleteCheckIn(checkIn: CheckIn) {
      Task {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
          showDeleteCheckInConfirmationDialog = false
          withAnimation {
            checkIns.remove(object: checkIn)
          }
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

    func fetchActivityFeedItems(onComplete: (() -> Void)? = nil) {
      let (from, to) = getPagination(page: page, size: pageSize)
      Task {
        await MainActor.run {
          self.isLoading = true
        }

        switch await repository.checkIn.getActivityFeed(from: from, to: to) {
        case let .success(checkIns):
          await MainActor.run {
            self.checkIns.append(contentsOf: checkIns)
            self.page += 1
            self.isLoading = false
          }

          if let onComplete {
            onComplete()
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}

struct NewCheckInCardView: View {
  enum LoadedFrom: Equatable {
    case checkIn
    case product
    case profile(Profile)
    case activity(Profile)
    case location(Location)
  }

  let checkIn: CheckIn
  let loadedFrom: LoadedFrom

  private var avoidStackingProfilePage: Bool {
    switch loadedFrom {
    case let .profile(profile):
      return profile.id == checkIn.profile.id
    default:
      return false
    }
  }

  var body: some View {
    VStack {
      VStack {
        header
        productSection
        if !checkIn.isEmpty() {
          checkInSection
        }
        if let imageUrl = checkIn.getImageUrl() {
          CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
            image
              .resizable()
              .scaledToFill()
          } placeholder: {
            ProgressView()
          }
        }
        if checkIn.taggedProfiles.count > 0 {
          VStack {
            HStack {
              Text(verbatim: "Tagged friends")
                .font(.subheadline)
                .fontWeight(.medium)
              Spacer()
            }
            HStack {
              ForEach(checkIn.taggedProfiles, id: \.id) {
                taggedProfile in
                NavigationLink(value: Route.profile(taggedProfile)) {
                  AvatarView(avatarUrl: taggedProfile.getAvatarURL(), size: 32, id: taggedProfile.id)
                }
              }
              Spacer()
            }
          }
          .padding([.trailing, .leading], 10)
        }
        footer
      }
      .padding([.top, .bottom], 10)
      .background(Color(.tertiarySystemBackground))
      .clipped()
    }
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
  }

  private var header: some View {
    NavigationLink(value: Route.profile(checkIn.profile)) {
      HStack {
        AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 30, id: checkIn.profile.id)
        Text(checkIn.profile.preferredName)
          .font(.system(size: 12, weight: .bold, design: .default))
          .foregroundColor(.primary)
        Spacer()
        if let location = checkIn.location {
          NavigationLink(value: Route.location(location)) {
            Text("\(location.name) \(location.country?.emoji ?? "")")
              .font(.system(size: 12, weight: .bold, design: .default))
              .foregroundColor(.primary)
          }
        }
      }
    }
    .padding([.leading, .trailing], 10)
    .disabled(avoidStackingProfilePage)
  }

  private var productSection: some View {
    OptionalNavigationLink(value: Route.product(checkIn.product), enabled: loadedFrom != .product) {
      VStack(alignment: .leading) {
        HStack {
          CategoryNameView(category: checkIn.product.category)

          ForEach(checkIn.product.subcategories, id: \.id) { subcategory in
            ChipView(title: subcategory.name, cornerRadius: 5)
          }

          Spacer()

          if let servingStyle = checkIn.servingStyle {
            ServingStyleLabelView(servingStyleName: servingStyle.name)
          }
        }

        Text(checkIn.product.getDisplayName(.fullName))
          .font(.system(size: 18, weight: .bold, design: .default))
          .foregroundColor(.primary)

        if let description = checkIn.product.description {
          Text(description)
            .font(.system(size: 12, weight: .medium, design: .default))
        }

        HStack {
          NavigationLink(
            value: Route.company(checkIn.product.subBrand.brand.brandOwner)
          ) {
            Text(checkIn.product.getDisplayName(.brandOwner))
              .font(.system(size: 16, weight: .bold, design: .default))
              .foregroundColor(.secondary)
              .lineLimit(nil)
          }

          if let manufacturer = checkIn.variant?.manufacturer,
             manufacturer.id != checkIn.product.subBrand.brand.brandOwner.id
          {
            Text("(\(manufacturer.name))")
              .font(.system(size: 16, weight: .bold, design: .default))
              .foregroundColor(.secondary)
              .lineLimit(nil)
          }

          Spacer()
        }
      }
    }
    .padding([.leading, .trailing], 10)
    .buttonStyle(.plain)
  }

  private var checkInSection: some View {
    OptionalNavigationLink(
      value: Route.checkIn(checkIn),
      enabled: loadedFrom == .checkIn
    ) {
      VStack(spacing: 8) {
        HStack {
          VStack(alignment: .leading, spacing: 8) {
            if let rating = checkIn.rating {
              RatingView(rating: rating)
            }

            if let review = checkIn.review {
              Text(review)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            }

            if let flavors = checkIn.flavors {
              HStack {
                WrappingHStack(flavors, id: \.self, spacing: .constant(4)) {
                  flavor in
                  ChipView(title: flavor.name.capitalized, cornerRadius: 5)
                }
              }
            }
          }
        }
      }
    }
    .padding([.leading, .trailing], 10)
    .buttonStyle(.plain)
  }

  private var footer: some View {
    HStack {
      OptionalNavigationLink(value: Route.checkIn(checkIn), enabled: loadedFrom != .checkIn) {
        if checkIn.isMigrated {
          Text("legacy check-in")
            .font(.system(size: 12, weight: .bold, design: .default))
        } else {
          Text(checkIn.getRelativeCreatedAt())
            .font(.system(size: 12, weight: .medium, design: .default))
        }
        Spacer()
      }
      .buttonStyle(.plain)
      Spacer()
      ReactionsView(checkIn: checkIn)
    }
    .padding([.leading, .trailing], 10)
  }
}
