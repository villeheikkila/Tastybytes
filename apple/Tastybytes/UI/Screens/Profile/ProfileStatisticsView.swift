import SwiftUI

struct ProfileStatisticsView: View {
  let logger = getLogger(category: "ProfileStatisticsView")
  @State private var categoryStatistics = [CategoryStatistics]()
  let client: Client
  let profile: Profile

  init(_ client: Client, profile: Profile) {
    self.client = client
    self.profile = profile
  }

  var body: some View {
    List {
      Section {
        ForEach(categoryStatistics) { category in
          DisclosureGroup(content: {
            SubcategoryStatisticsView(client, profile: profile, category: category)
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
        if !categoryStatistics.isEmpty {
          Text("Category")
        }
      }.headerProminence(.increased)
    }
    .refreshable {
      await loadStatistics()
    }
    .task {
      await loadStatistics()
    }
    .navigationTitle("Statistics")
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

struct SubcategoryStatisticsView: View {
  let logger = getLogger(category: "SubcategoryStatistics")
  @State private var subcategoryStatistics = [SubcategoryStatistics]()
  @State private var isLoading = false

  let client: Client
  let profile: Profile
  let category: CategoryStatistics

  init(_ client: Client, profile: Profile, category: CategoryStatistics) {
    self.client = client
    self.profile = profile
    self.category = category
  }

  var body: some View {
    Section {
      if isLoading {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding([.top, .bottom], 8)
      }
      ForEach(subcategoryStatistics) { subcategory in
        HStack {
          Text(subcategory.name).font(.caption).bold()
          Spacer()
          Text(String(subcategory.count)).font(.caption).bold()
        }
      }
    } header: {
      Label("Subcategories", systemImage: "tag").font(.caption).bold()
    }
    .task {
      await loadSubcategoryStatistics()
    }
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
