import EnvironmentModels
import Models
import SwiftUI

struct AppLogoView: View {
    let appIcon: AppIcon?
    let size: Double

    init(appIcon: AppIcon? = nil, size: Double? = nil) {
        self.appIcon = appIcon
        self.size = size ?? min(UIScreen.main.bounds.width / 4, 300)
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

#Preview {
    AppLogoView()
}
