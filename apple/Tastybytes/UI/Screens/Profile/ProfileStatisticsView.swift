import SwiftUI

struct ProfileStatisticsView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    List {
      Section {
        ForEach(viewModel.categoryStatistics) { category in
          DisclosureGroup(content: {
            SubcategoryStatistics(viewModel.client, profile: viewModel.profile, category: category)
          }, label: {
            HStack {
              CategoryNameView(category: category)
              Spacer()
              Text(String(category.count)).font(.caption).bold()
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 32))
          })
        }
      } header: {
        if !viewModel.categoryStatistics.isEmpty {
          Text("Category")
        }
      }.headerProminence(.increased)
    }
    .refreshable {
      await viewModel.loadStatistics()
    }
    .task {
      await viewModel.loadStatistics()
    }
    .navigationTitle("Statistics")
  }
}

struct SubcategoryStatistics: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, profile: Profile, category: CategoryStatistics) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile, category: category))
  }

  var body: some View {
    Section {
      if viewModel.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding([.top, .bottom], 8)
      }
      ForEach(viewModel.subcategoryStatistics) { subcategory in
        HStack {
          Text(subcategory.label).font(.caption).bold()
          Spacer()
          Text(String(subcategory.count)).font(.caption).bold()
        }
      }
    } header: {
      Label("Subcategories", systemImage: "tag").font(.caption).bold()
    }
    .task {
      await viewModel.loadSubcategoryStatistics()
    }
  }
}

extension SubcategoryStatistics {
  @MainActor
  class ViewModel: ObservableObject {
    let logger = getLogger(category: "SubcategoryStatistics")
    let client: Client
    let profile: Profile
    let category: CategoryStatistics

    @Published var subcategoryStatistics = [CategoryStatistics]()
    @Published var isLoading = false

    init(_ client: Client, profile: Profile, category: CategoryStatistics) {
      self.client = client
      self.profile = profile
      self.category = category
    }

    func loadSubcategoryStatistics() async {
      isLoading = true
      switch await client.profile.getSubcategoryStatistics(userId: profile.id, categoryId: category.id) {
      case let .success(subcategoryStatistics):
        withAnimation {
          self.subcategoryStatistics = subcategoryStatistics
        }
      case let .failure(error):
        logger.error("failed loading subcategory statistics: \(error.localizedDescription)")
      }
      isLoading = false
    }
  }
}

extension ProfileStatisticsView {
  @MainActor
  class ViewModel: ObservableObject {
    let logger = getLogger(category: "ProfileStatisticsView")
    let client: Client
    let profile: Profile

    @Published var categoryStatistics = [CategoryStatistics]()

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    func loadStatistics() async {
      switch await client.profile.getCategoryStatistics(userId: profile.id) {
      case let .success(categoryStatistics):
        withAnimation {
          self.categoryStatistics = categoryStatistics
        }
      case let .failure(error):
        logger.error("failed loading category statistics: \(error.localizedDescription)")
      }
    }
  }
}
