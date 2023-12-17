import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ContentView: View {
    @Environment(\.repository) private var repository

    var body: some View {
        SplashScreenProvider {
            SubscriptionProvider {
                EnvironmentProvider(repository: repository) {
                    AuthEventObserver(
                        authenticated: {
                            OnboardingProvider {
                                AuthenticatedContentInitializer {
                                    if isPadOrMac() {
                                        SideBarView()
                                    } else {
                                        TabsView()
                                    }
                                }
                            }
                        }, unauthenticated: {
                            AuthenticationScreen()
                        }, loading: {
                            SplashScreen()
                        }
                    )
                }
            }
        }
    }
}
