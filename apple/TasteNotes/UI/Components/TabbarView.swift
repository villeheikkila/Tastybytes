import SwiftUI

struct TabbarView: View {
    let profile: Profile
    @EnvironmentObject var notificationManager: NotificationManager
    @State var selection = Tab.activity

    // The initialize the view model for search page here because searchable needs to be a direct child of NavigationStack
    // TODO: Investigate if there is a better way to do this (created: 17.11.2022)
    @StateObject private var searchScreenViewModel = SearchScreenViewModel()

    var body: some View {
        TabView(selection: $selection) {
            activityScreen
            searchScreen
            notificationScreen
            profileScreen
        }
        .if(selection == Tab.search) { view in
            view
                .searchable(text: $searchScreenViewModel.searchTerm)
                .searchScopes($searchScreenViewModel.searchScope) {
                    Text("Products").tag(SearchScope.products)
                    Text("Companies").tag(SearchScope.companies)
                    Text("Users").tag(SearchScope.users)
                }
                .onSubmit(of: .search, searchScreenViewModel.search)
        }
        .navigationTitle(selection.title)
        .toolbar {
            if selection == Tab.profile || selection == Tab.activity {
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

            if selection == Tab.search {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        searchScreenViewModel.showBarcodeScanner.toggle()
                    }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }

            if selection == Tab.notifications {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            notificationManager.deleteAll()
                        }) {
                            Label("Delete all notifications", systemImage: "trash")
                        }
                    } label: {
                        Text("Mark all read")
                    } primaryAction: {
                        notificationManager.markAllAsRead()
                    }
                }
            }
        }
    }

    var activityScreen: some View {
        ActivityScreenView(profile: profile)
            .tabItem {
                Image(systemName: "list.star")
                Text("Activity")
            }
            .tag(Tab.activity)
    }

    var searchScreen: some View {
        SearchScreenView(viewModel: searchScreenViewModel)
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(Tab.search)
    }

    var notificationScreen: some View {
        NotificationScreenView()
            .tabItem {
                Image(systemName: "bell")
                Text("Notifications")
            }
            .badge(notificationManager
                .notifications
                .filter { $0.seenAt == nil }
                .count
            )
            .tag(Tab.notifications)
    }

    var profileScreen: some View {
        ProfileScreenView(profile: profile)
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(Tab.profile)
    }
}

enum Tab: Int, Equatable {
    case activity = 1
    case search = 2
    case notifications = 3
    case profile = 4

    var title: String {
        switch self {
        case .activity:
            return "Activity"
        case .search:
            return "Search"
        case .notifications:
            return "Notifications"
        case .profile:
            return ""
        }
    }
}

class ActivityScreenViewModel: ObservableObject {
    @Published var checkIns = [CheckIn]()
    @Published var isLoading = false
    let pageSize = 10
    var page = 0

    func refresh() {
        DispatchQueue.main.async {
            self.page = 0
            self.checkIns = [CheckIn]()
            self.fetchActivityFeedItems()
        }
    }

    func onCheckInDelete(checkIn: CheckIn) {
        checkIns.remove(object: checkIn)
    }

    func onCheckInUpdate(checkIn: CheckIn) {
        if let index = checkIns.firstIndex(of: checkIn) {
            checkIns[index] = checkIn
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

                if let onComplete = onComplete {
                    onComplete()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}
