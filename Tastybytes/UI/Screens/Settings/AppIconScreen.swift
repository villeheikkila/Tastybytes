import SwiftUI

struct AppIconScreen: View {
    @Environment(ProfileManager.self) private var profileManager
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

                Label("Selected", systemSymbol: .checkmark)
                    .labelStyle(.iconOnly)
                    .opacity(appIcon == selection ? 1 : 0)
            }
            .padding(4)
        }
        .navigationBarTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selection) { _, icon in
            if let icon, selection != getCurrentAppIcon() {
                UIApplication.shared.setAlternateIconName(icon == AppIcon.ramune ? nil : icon.rawValue)
                profileManager.appIcon = icon
            }
        }
        .onAppear {
            selection = getCurrentAppIcon()
        }
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

enum AppIcon: String {
    case ramune = "AppIcon"
    case cola = "AppIconCola"
    case juice = "AppIconJuice"
    case energyDrink = "AppIconEnergyDrink"
    case kombucha = "AppIconKombucha"

    var logo: ImageResource {
        switch self {
        case .ramune:
            .projectLogo
        case .cola:
            .projectLogoCola
        case .energyDrink:
            .projectLogoEnergyDrink
        case .juice:
            .juice
        case .kombucha:
            .projectLogoKombucha
        }
    }

    var label: String {
        switch self {
        case .ramune:
            "Ramune"
        case .juice:
            "Juice"
        case .energyDrink:
            "Energy Drink"
        case .kombucha:
            "Kombucha"
        case .cola:
            "Cola"
        }
    }

    var icon: ImageResource {
        switch self {
        case .ramune:
            return .ramune
        case .juice:
            return .juice
        case .energyDrink:
            return .energyDrink
        case .kombucha:
            return .kombucha
        case .cola:
            return .cola
        }
    }
}
