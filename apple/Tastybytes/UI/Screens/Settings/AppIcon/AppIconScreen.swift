import SwiftUI

struct AppIconScreen: View {
  @State private var appIcons = [AppIcon.ramune, AppIcon.cola, AppIcon.energyDrink, AppIcon.juice, AppIcon.kombucha]
  @State private var selection: AppIcon?

  var body: some View {
    List(appIcons, id: \.self, selection: $selection) { appIcon in
      HStack(spacing: 12) {
        Image(appIcon.icon)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 40, height: 40)
          .cornerRadius(8)
          .accessibilityLabel("\(appIcon.label) app icon")

        Text(appIcon.label)
          .fontWeight(.medium)

        Spacer()

        Label("Selected", systemImage: "checkmark")
          .labelStyle(.iconOnly)
          .opacity(appIcon == selection ? 1 : 0)
      }
      .padding(4)
    }
    .navigationBarTitle("App Icon")
    .onChange(of: selection) { icon in
      if let icon, selection != getCurrentAppIcon() {
        UIApplication.shared.setAlternateIconName(icon == AppIcon.ramune ? nil : icon.rawValue)
      }
    }
    .onAppear {
      selection = getCurrentAppIcon()
    }
  }

  @MainActor
  func getCurrentAppIcon() -> AppIcon {
    if let alternateAppIcon = UIApplication.shared.alternateIconName {
      return AppIcon(rawValue: alternateAppIcon) ?? AppIcon.ramune
    } else {
      return AppIcon.ramune
    }
  }
}
