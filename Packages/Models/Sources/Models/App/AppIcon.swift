import SwiftUI

public enum AppIcon: String, CaseIterable, Identifiable {
    public var id: String {
        rawValue
    }

    case ramune = "AppIcon"
    case cola = "AppIconCola"
    case juice = "AppIconJuice"
    case energyDrink = "AppIconEnergyDrink"
    case kombucha = "AppIconKombucha"

    @MainActor
    public static var currentAppIcon: Self {
        if let alternateAppIcon = UIApplication.shared.alternateIconName {
            return .init(rawValue: alternateAppIcon) ?? AppIcon.ramune
        }
        return .ramune
    }
}
