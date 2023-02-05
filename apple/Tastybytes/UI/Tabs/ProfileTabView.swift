import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  let client: Client
  @StateObject private var router = Router()
  @State private var scrollToTop = 0
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding private var resetNavigationOnTab: Tab?

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      ProfileView(client, profile: profileManager.getProfile(), scrollToTop: $scrollToTop)
        .navigationTitle(profileManager.getProfile().preferredName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          toolbarContent
        }
        .withRoutes(client)
    }
    .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
      if tab == .profile {
        if router.path.isEmpty {
          scrollToTop += 1
        } else {
          router.reset()
        }
        resetNavigationOnTab = nil
      }
    }
    .environmentObject(router)
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
