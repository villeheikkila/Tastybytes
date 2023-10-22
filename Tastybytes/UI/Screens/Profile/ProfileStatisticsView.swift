import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileStatisticsView: View {
    private let logger = Logger(category: "ProfileStatisticsView")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var categoryStatistics = [CategoryStatistics]()
    @State private var alertError: AlertError?

    let profile: Profile

    var body: some View {
        List {
            Section {
                ForEach(categoryStatistics) { category in
                    DisclosureGroup(content: {
                        SubcategoryStatisticsView(profile: profile, category: category)
                    }, label: {
                        HStack {
                            CategoryNameView(category: category, withBorder: false)
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
            }
            .headerProminence(.increased)

            Section {
                TimePeriodStatisticView(profile: profile)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Statistics")
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await loadStatistics()
            }
        #endif
            .alertError($alertError)
                .task {
                    await loadStatistics()
                }
    }

    func loadStatistics() async {
        switch await repository.profile.getCategoryStatistics(userId: profile.id) {
        case let .success(categoryStatistics):
            await MainActor.run {
                withAnimation {
                    self.categoryStatistics = categoryStatistics
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed loading category statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct SubcategoryStatisticsView: View {
    private let logger = Logger(category: "SubcategoryStatistics")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var subcategoryStatistics = [SubcategoryStatistics]()
    @State private var isLoading = false
    @State private var alertError: AlertError?

    let profile: Profile
    let category: CategoryStatistics

    var body: some View {
        Section {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            ForEach(subcategoryStatistics) { subcategory in
                RouterLink(screen: .profileProductsByFilter(
                    profile,
                    Product
                        .Filter(
                            category: category.category,
                            subcategory: subcategory.subcategory,
                            onlyNonCheckedIn: false,
                            sortBy: Product.Filter.SortBy.highestRated
                        )
                )) {
                    HStack {
                        Text(subcategory.name)
                        Spacer()
                        Text(String(subcategory.count))
                    }
                    .font(.caption)
                    .bold()
                }
            }
        } header: {
            RouterLink("Subcategories (all)", systemImage: "tag", screen: .profileProductsByFilter(
                profile,
                Product
                    .Filter(category: category.category, subcategory: nil, onlyNonCheckedIn: false,
                            sortBy: Product.Filter.SortBy.highestRated)
            ))
            .foregroundColor(Color.primary)
            .font(.caption)
            .bold()
        }
        .alertError($alertError)
        .task {
            await loadSubcategoryStatistics()
        }
    }

    func loadSubcategoryStatistics() async {
        guard isLoading == false, subcategoryStatistics.isEmpty else { return }
        isLoading = true
        switch await repository.profile.getSubcategoryStatistics(userId: profile.id, categoryId: category.id) {
        case let .success(subcategoryStatistics):
            await MainActor.run {
                withAnimation {
                    self.subcategoryStatistics = subcategoryStatistics
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed loading subcategory statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}
