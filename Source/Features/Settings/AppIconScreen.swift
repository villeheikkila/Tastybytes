
import Models
import SwiftUI

struct AppIconScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @State private var selection: AppIcon?

    var body: some View {
        List(AppIcon.allCases, id: \.self, selection: $selection) { appIcon in
            HStack(spacing: 12) {
                Image(appIcon.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .accessibilityLabel(appIcon.label)

                Text(appIcon.label)
                    .fontWeight(.medium)

                Spacer()

                Label("settings.appIcon.selected", systemImage: "checkmark")
                    .labelStyle(.iconOnly)
                    .opacity(appIcon == selection ? 1 : 0)
            }
            .padding(4)
        }
        .navigationBarTitle("settings.appIcon.title")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selection) { _, newValue in
            if let newValue, newValue != AppIcon.currentAppIcon {
                profileModel.setAppIcon(newValue)
            }
        }
        .onAppear {
            selection = AppIcon.currentAppIcon
        }
    }
}
