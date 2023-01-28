enum AppIcon: String {
  case ramune = "AppIcon"
  case cola = "AppIconCola"
  case juice = "AppIconJuice"
  case energyDrink = "AppIconEnergyDrink"
  case kombucha = "AppIconKombucha"

  var label: String {
    switch self {
    case .ramune:
      return "Ramune"
    case .juice:
      return "Juice"
    case .energyDrink:
      return "Energy Drink"
    case .kombucha:
      return "Kombucha"
    case .cola:
      return "Cola"
    }
  }
}
