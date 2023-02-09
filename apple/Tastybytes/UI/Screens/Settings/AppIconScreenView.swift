import SwiftUI

struct AppIconScreenView: View {
  @State private var appIcons = [AppIcon.ramune, AppIcon.cola, AppIcon.energyDrink, AppIcon.juice, AppIcon.kombucha]
  @State private var selection: AppIcon?

  var body: some View {
    List(appIcons, id: \.self, selection: $selection) { icon in
      HStack(spacing: 12) {
        Image(uiImage: .init(named: icon.rawValue) ?? .init())
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 40, height: 40)
          .cornerRadius(8)

        Text(icon.label)
          .fontWeight(.medium)

        Spacer()

        if icon == selection {
          Image(systemName: "checkmark")
        }
      }
      .padding(4)
    }
    .navigationBarTitle("App Icon")
    .onChange(of: selection) { icon in
      if let icon, selection != getCurrentAppIcon() {
        UIApplication.shared.setAlternateIconName(icon == AppIcon.ramune ? nil : icon.rawValue)
      }
    }
    .onAppear {
      selection = getCurrentAppIcon()
    }
  }
}
