import Components
import EnvironmentModels
import PhotosUI
import SwiftUI

struct OnboardingAvatarScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @FocusState var focusedField: OnboardField?
    @State private var selectedItem: PhotosPickerItem?

    let onContinue: () -> Void

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
                        AvatarView(
                            avatarUrl: profileEnvironmentModel.profile.avatarUrl,
                            size: 140,
                            id: profileEnvironmentModel.id
                        )
                    }
                    .onChange(of: selectedItem) { _, newValue in
                        guard let newValue else { return }
                        Task { await profileEnvironmentModel.uploadAvatar(newAvatar: newValue) }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .simultaneousGesture(DragGesture())
        .accessibility(hidden: true)
    }
}
