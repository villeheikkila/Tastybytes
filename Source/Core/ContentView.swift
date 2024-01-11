import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ContentView: View {
    @Environment(\.repository) private var repository

    var body: some View {
        EnvironmentProvider(repository: repository) {
            SubscriptionProvider {
                DeviceInfoProvider {
                    SplashScreenProvider {
                        AppStateObserver {
                            AuthStateObserver {
                                ProfileStateObserver {
                                    OnboardingStateObserver {
                                        NotificationObserver {
                                            LayoutSelector(sidebar: {
                                                SideBarView()
                                            }, tab: {
                                                TabsView()
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
