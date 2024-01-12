import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ContentView: View {
    var body: some View {
        Providers {
            Observers {
                LayoutSelector(sidebar: {
                    SideBarView()
                }, tab: {
                    TabsView()
                })
            }
        }
    }
}

struct Providers<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        EnvironmentProvider {
            SubscriptionProvider {
                DeviceInfoProvider {
                    SplashScreenProvider {
                        content()
                    }
                }
            }
        }
    }
}

struct Observers<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        AppStateObserver {
            AuthStateObserver {
                ProfileStateObserver {
                    OnboardingStateObserver {
                        NotificationObserver {
                            content()
                        }
                    }
                }
            }
        }
    }
}
