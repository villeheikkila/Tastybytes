enum AppIcon: String {
  case ramune = "AppIcon"
  case cola = "AppIconCola"
  case juice = "AppIconJuice"
  case energyDrink = "AppIconEnergyDrink"
  case kombucha = "AppIconKombucha"

  var logo: String {
    switch self {
    case .ramune:
      return "ProjectLogo"
    case .cola:
      return "ProjectLogoCola"
    case .energyDrink:
      return "ProjectLogoEnergyDrink"
    case .juice:
      return "ProjectLogoJuice"
    case .kombucha:
      return "ProjectLogoKombucha"
    }
  }

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

  var icon: String {
    switch self {
    case .ramune:
      return "Ramune"
    case .juice:
      return "Juice"
    case .energyDrink:
      return "EnergyDrink"
    case .kombucha:
      return "Kombucha"
    case .cola:
      return "Cola"
    }
  }
}
