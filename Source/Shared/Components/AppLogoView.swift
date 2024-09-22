import Models
import SwiftUI

struct AppLogoView: View {
    let appIcon: AppIcon?

    init(appIcon: AppIcon? = nil) {
        self.appIcon = appIcon
    }

    private var icon: AppIcon {
        appIcon ?? .currentAppIcon
    }

    var body: some View {
        Image(icon.logo)
            .resizable()
            .aspectRatio(contentMode: .fill)
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
