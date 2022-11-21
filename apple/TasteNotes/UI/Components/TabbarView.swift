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
                .searchable(text: $searchScreenViewModel.searchTerm, tokens: $searchScreenViewModel.tokens) { token in
                    switch token {
                    case .chips: Text("Chips")
                    case .candy: Text("Candy")
                    case .chewing_gum: Text("Chewing Gum")
                    case .fruit: Text("Fruit")
                    case .popcorn: Text("Popcorn")
                    case .ingredient: Text("Ingredient")
                    case .beverage: Text("Beverage")
                    case .convenience_food: Text("Convenience Food")
                    case .cheese: Text("Cheese")
                    case .snacks: Text("Snacks")
                    case .juice: Text("Juice")
                    case .chocolate: Text("Chocolate")
                    case .cocoa: Text("Cocoa")
                    case .ice_cream: Text("Ice Cream")
                    case .pizza: Text("Pizza")
                    case .protein: Text("Protein")
                    case .milk: Text("Milk")
                    case .alcoholic_beverage: Text("Alcoholic Beverage")
                    case .cereal: Text("Cereal")
                    case .pastry: Text("Pastry")
                    case .spice: Text("Spice")
                    case .noodles: Text("Noodles")
                    case .tea: Text("Tea")
                    case .coffee: Text("Coffee")
                    }
                }
                .searchScopes($searchScreenViewModel.searchScope) {
                    Text("Products").tag(SearchScope.products)
                    Text("Companies").tag(SearchScope.companies)
                    Text("Users").tag(SearchScope.users)
                }
                .onSubmit(of: .search, searchScreenViewModel.search)
        }
        .navigationTitle(selection == Tab.profile ? profile.preferredName : selection.title)
        .navigationBarTitleDisplayMode(selection == Tab.profile ? .inline : .automatic)
        .toolbar {
            toolbarContent
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
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
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
        } else if selection == Tab.search {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    searchScreenViewModel.showBarcodeScanner.toggle()
                }) {
                    Image(systemName: "barcode.viewfinder")
                }
            }
        } else if selection == Tab.notifications {
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
        } else {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                NavigationLink(value: Route.currentUserFriends) {
                    Image(systemName: "person.2").imageScale(.large)
                }
            }
        }
    }
}

extension TabbarView {
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
}


