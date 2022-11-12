import SwiftUI

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var splashScreenManager = SplashScreenManager()


    var body: some Scene {
        WindowGroup {
             ZStack {
                 RootView()
                 if splashScreenManager.state != .finished {
                     SplashScreenView()
                 }
             }.environmentObject(splashScreenManager)
         }
    }
}
