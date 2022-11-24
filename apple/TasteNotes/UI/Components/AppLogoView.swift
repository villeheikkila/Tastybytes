import SwiftUI

struct AppLogoView: View {
    func getCurrentProjectLogo() -> String {
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

    var body: some View {
        Image(getCurrentProjectLogo())
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
    }
}

struct AppLogoView_Previews: PreviewProvider {
    static var previews: some View {
        AppLogoView()
    }
}
