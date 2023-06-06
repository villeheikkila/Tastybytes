import SwiftUI

struct AppLogoView: View {
  let size = min(UIScreen.main.bounds.width / 4.5, 300)

  var body: some View {
    Image(getCurrentProjectLogo())
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: size, height: size)
      .accessibility(hidden: true)
  }

  private func getCurrentProjectLogo() -> String {
    switch getCurrentAppIcon() {
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
}

#Preview {
    AppLogoView()
}
