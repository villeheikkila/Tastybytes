import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct AppLogoView: View {
    let appIcon: AppIcon?
    let size: Double

    init(appIcon: AppIcon? = nil, size: Double? = nil) {
        self.appIcon = appIcon
        self.size = size ?? 120
    }

    var body: some View {
        Image(appIcon?.logo ?? getCurrentAppIcon().logo)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .accessibility(hidden: true)
    }
}

extension AppIcon {
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

    var label: LocalizedStringKey {
        switch self {
        case .ramune:
            "appIcon.ramune"
        case .juice:
            "appIcon.juice"
        case .energyDrink:
            "appIcon.energyDrink"
        case .kombucha:
            "appIcon.kombucha"
        case .cola:
            "appIcon.cola"
        }
    }

    var icon: ImageResource {
        switch self {
        case .ramune:
            .ramune
        case .juice:
            .juice
        case .energyDrink:
            .energyDrink
        case .kombucha:
            .kombucha
        case .cola:
            .cola
        }
    }
}

#Preview {
    AppLogoView()
}
