import Charts
import PhotosUI
import SwiftUI

struct ProfileTab: View {
  let client: Client
  @State private var scrollToTop = 0
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding private var resetNavigationOnTab: Tab?

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    InitializeRouter(client) { router in
      ProfileView(client, profile: profileManager.getProfile(), scrollToTop: $scrollToTop, isCurrentUser: true)
        .navigationTitle(profileManager.getProfile().preferredName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(action: { router.navigate(sheet: .nameTag(onSuccess: { profileId in
              router.fetchAndNavigateTo(client, NavigatablePath.profile(id: profileId), resetStack: false)
            })) }, label: {
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
    }
  }
}
