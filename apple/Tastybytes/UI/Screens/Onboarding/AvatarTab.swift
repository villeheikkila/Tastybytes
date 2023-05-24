import PhotosUI
import SwiftUI

struct AvatarTab: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @FocusState var focusedField: OnboardField?
  @State private var selectedItem: PhotosPickerItem?
  @Binding var currentTab: OnboardTabsView.Tab

  var body: some View {
    Form {
      Text("Now, add a photo")
        .font(.largeTitle)
        .fontWeight(.semibold)

      Section {
        HStack {
          Spacer()
          PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
          ) {
            AvatarView(avatarUrl: profileManager.profile.avatarUrl, size: 140, id: profileManager.id)
          }
          .onChange(of: selectedItem) { newValue in
            guard let newValue else { return }
            Task { await profileManager.uploadAvatar(newAvatar: newValue) }
          }
          Spacer()
        }
      }
      .listRowBackground(Color.clear)
    }
    .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
      if let nextTab = OnboardTabsView.Tab(rawValue: currentTab.rawValue + 1) {
        withAnimation {
          currentTab = nextTab
        }
      }
    }))
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .scrollDisabled(true)
    .accessibility(hidden: true)
  }
}
