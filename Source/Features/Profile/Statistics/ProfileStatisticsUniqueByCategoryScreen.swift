import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileStatisticsUniqueByCategoryScreen: View {
    private let logger = Logger(category: "ProfileStatisticsUniqueByCategoryScreen")
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var categoryStatistics = [CategoryStatistics]()

    let profile: Profile

    var body: some View {
        List(categoryStatistics) { category in
            ProfileStatisticsUniqueByCategoryRow(profile: profile, category: category)
        }
        .listStyle(.plain)
        .overlay {
            if state == .populated, categoryStatistics.isEmpty {
                ContentUnavailableView("profileStatistics.uniqueByCategory.empty.title", systemImage: "tray")
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "profileStatistics.uniqueByCategory.screen.failedToLoad", errorAction: {
                    await loadStatistics()
                })
            }
        }
        .refreshable {
            await loadStatistics()
        }
        .navigationTitle("profileStatistics.uniqueByCategory.navigationTitle")
        .initialTask {
            await loadStatistics()
        }
    }

    private func loadStatistics() async {
        do {
            let categoryStatistics = try await repository.profile.getCategoryStatistics(userId: profile.id)
            withAnimation {
                self.categoryStatistics = categoryStatistics
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed loading category statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ProfileStatisticsUniqueByCategoryRow: View {
    let profile: Profile
    let category: CategoryStatistics

    var body: some View {
        DisclosureGroup(content: {
            SubcategoryStatisticsView(profile: profile, category: category)
        }, label: {
            HStack {
                CategoryNameView(category: category, withBorder: false)
                Spacer()
                Text(category.count.formatted()).font(.caption).bold()
            }
        })
    }
}

struct SubcategoryStatisticsView: View {
    private let logger = Logger(category: "SubcategoryStatisticsView")
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var subcategoryStatistics = [SubcategoryStatistics]()

    let profile: Profile
    let category: CategoryStatistics

    var body: some View {
        Section {
            if state == .populated {
                SubcategoryStatisticsRow(profile: profile, category: category.category, subcategory: nil)
                ForEach(subcategoryStatistics) { subcategory in
                    SubcategoryStatisticsRow(profile: profile, category: category.category, subcategory: subcategory)
                }
            } else {
                ScreenStateOverlayView(state: state) {
                    await loadSubcategoryStatistics()
                }
            }
        }
        .task {
            await loadSubcategoryStatistics()
        }
    }

    private func loadSubcategoryStatistics() async {
        do {
            let subcategoryStatistics = try await repository.profile.getSubcategoryStatistics(userId: profile.id, categoryId: category.id)
            withAnimation {
                self.subcategoryStatistics = subcategoryStatistics
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed loading subcategory statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct SubcategoryStatisticsRow: View {
    let profile: Profile
    let category: Models.Category
    let subcategory: SubcategoryStatistics?

    var body: some View {
        RouterLink(open: .screen(.profileProductsByFilter(
            profile,
            .init(
                category: category,
                subcategory: subcategory?.subcategory,
                sortBy: .highestRated
            )
        )
        )) {
            if let subcategory {
                HStack {
                    Text(subcategory.name)
                    Spacer()
                    Text(subcategory.count.formatted())
                }
                .font(.caption)
            } else {
                Text("subcategoryStatistics.all.open")
                    .foregroundColor(.primary)
                    .font(.caption)
                    .bold()
            }
        }
    }
}
