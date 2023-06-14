import PhotosUI
import SwiftUI

struct AvatarOnboarding: View {
    @Environment(ProfileManager.self) private var profileManager
    @FocusState var focusedField: OnboardField?
    @State private var selectedItem: PhotosPickerItem?
    @Binding var currentTab: OnboardingScreen.Tab

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
                    .onChange(of: selectedItem) { _, newValue in
                        guard let newValue else { return }
                        Task { await profileManager.uploadAvatar(newAvatar: newValue) }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
        }
        .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
            if let nextTab = currentTab.next {
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
