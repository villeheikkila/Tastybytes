import SwiftUI

public enum AppIcon: String {
    case ramune = "AppIcon"
    case cola = "AppIconCola"
    case juice = "AppIconJuice"
    case energyDrink = "AppIconEnergyDrink"
    case kombucha = "AppIconKombucha"

    @MainActor
    public static var currentAppIcon: Self {
        #if !os(watchOS)
            if let alternateAppIcon = UIApplication.shared.alternateIconName {
                return .init(rawValue: alternateAppIcon) ?? AppIcon.ramune
            }
        #endif
        return .ramune
    }
}
