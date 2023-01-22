import SwiftUI

struct AppIconScreenView: View {
  @State private var appIcons = [AppIcon.ramune, AppIcon.cola, AppIcon.energyDrink, AppIcon.juice, AppIcon.kombucha]
  @State private var selection: AppIcon?

  var body: some View {
    List(appIcons, id: \.self, selection: $selection) { name in
      HStack(spacing: 12) {
        Image(uiImage: UIImage(named: name.rawValue) ?? UIImage())
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 40, height: 40)
          .cornerRadius(8)

        Text(getLabel(name))
          .fontWeight(.medium)
      }
      .padding(4)
    }
    .navigationBarTitle("App Icon")
    .onChange(of: selection) { icon in
      if let icon, icon != getCurrentAppIcon() {
        UIApplication.shared.setAlternateIconName(icon == AppIcon.ramune ? nil : icon.rawValue)
      }
    }.task {
      self.selection = getCurrentAppIcon()
    }
  }

  private func getLabel(_ name: AppIcon) -> String {
    switch name {
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
