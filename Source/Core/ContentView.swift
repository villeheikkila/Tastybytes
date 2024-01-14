import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ContentView: View {
    var body: some View {
        EnvironmentProvider {
            DeviceInfoProvider {
                SplashScreenProvider {
                    PhaseObserver {
                        AppStateObserver {
                            SubscriptionProvider {
                                AuthStateObserver {
                                    ProfileStateObserver {
                                        OnboardingStateObserver {
                                            NotificationObserver {
                                                LayoutSelector()
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
}
