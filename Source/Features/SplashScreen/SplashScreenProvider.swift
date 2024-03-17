import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct SplashScreenProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()
            if appEnvironmentModel.splashScreenState != .finished {
                SplashScreen()
            }
        }
    }
}

@MainActor
struct SplashScreen: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var dismissAnimation = false
    @State private var startFadeoutAnimation = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        ZStack {
            #if !os(watchOS)
                Color(.systemBackground)
                    .ignoresSafeArea()
            #endif
            VStack(spacing: 24) {
                AppLogoView()
                    .scaleEffect(size)
                    .opacity(opacity)
                AppNameView()
                    .foregroundColor(.primary.opacity(0.80))
            }
        }
        .onReceive(
            Timer
                .publish(every: 0.5, on: .current, in: .common)
                .autoconnect()
        ) { _ in
            updateAnimation()
        }
        .opacity(startFadeoutAnimation ? 0 : 1)
    }

    private func updateAnimation() {
        switch appEnvironmentModel.splashScreenState {
        case .showing:
            withAnimation(.easeIn(duration: 1)) {
                size = 0.9
                opacity = 1.00
            }
        case .dismissing:
            if dismissAnimation == false {
                withAnimation(.linear) {
                    dismissAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            break
        }
    }
}

@MainActor
struct AppLogoView: View {
    let appIcon: AppIcon?

    init(appIcon: AppIcon? = nil) {
        self.appIcon = appIcon
    }

    var body: some View {
        Image(appIcon?.logo ?? getCurrentAppIcon().logo)
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

@MainActor
struct AppNameView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let size: Double

    init(size: Double = 28) {
        self.size = size
    }

    var body: some View {
        Text(appEnvironmentModel.infoPlist.appName)
            .font(.custom("Comfortaa-Bold", size: size))
            .bold()
    }
}
