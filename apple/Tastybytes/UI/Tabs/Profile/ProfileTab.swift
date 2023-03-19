import Charts
import PhotosUI
import SwiftUI

struct ProfileTab: View {
  let client: Client
  @StateObject private var router = Router()
  @State private var scrollToTop = 0
  @State private var showProfileQrCode = false
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding private var resetNavigationOnTab: Tab?

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      ProfileView(client, profile: profileManager.getProfile(), scrollToTop: $scrollToTop, isCurrentUser: true)
        .navigationTitle(profileManager.getProfile().preferredName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          toolbarContent
        }
        .withRoutes(client)
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(client, detailPage, resetStack: true)
          }
        }
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
    .sheet(isPresented: $showProfileQrCode) {
      NavigationStack {
        NameTagSheet(onSuccess: { profileId in
          router.fetchAndNavigateTo(client, NavigatablePath.profile(id: profileId), resetStack: false)
        })
      }
      .presentationDetents([.medium])
    }
    .environmentObject(router)
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      Button(action: { showProfileQrCode.toggle() }, label: {
        Label("Show name tag", systemImage: "qrcode")
          .labelStyle(.iconOnly)
      })
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      RouteLink(to: .settings) {
        Label("Settings page", systemImage: "gear")
          .labelStyle(.iconOnly)
      }
    }
  }
}
