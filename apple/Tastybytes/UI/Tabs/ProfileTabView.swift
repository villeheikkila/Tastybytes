import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  let client: Client
  @StateObject private var router = Router()
  @State private var scrollToTop = 0
  @State private var showProfileQrCode = false
  @State private var showNameTagScanner = false
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
        VStack(spacing: 20) {
          if !showNameTagScanner {
            CreateQRCodeView(qrCodeText: NavigatablePath.profile(id: profileManager.getId()).url.absoluteString)
            Button(action: {
              showNameTagScanner.toggle()
            }) {
              HStack {
                Spacer()
                Label("Scan Name Tag", systemImage: "qrcode.viewfinder")
                Spacer()
              }
            }
          } else {
            ScannerView(scanTypes: [.qr]) { response in
              if case let .success(result) = response {
                let string = result.barcode.components(separatedBy: "/").last
                if let string, let profileId = UUID(uuidString: string) {
                  router.fetchAndNavigateTo(client, NavigatablePath.profile(id: profileId))
                }
              }
            }
            Button(action: {
              showNameTagScanner.toggle()
            }) {
              HStack {
                Spacer()
                Label("Show Name Tag", systemImage: "qrcode")
                Spacer()
              }
            }
          }
        }
        .navigationTitle("Name Tag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
          trailing: ShareLink("Share", item: NavigatablePath.profile(id: profileManager.getId()).url)
        )
      }
      .presentationDetents([.medium])
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
      Button(action: {
        showProfileQrCode.toggle()
      }) {
        Image(systemName: "qrcode")
      }
      NavigationLink(value: Route.settings) {
        Image(systemName: "gear").imageScale(.large)
      }
    }
  }
}
