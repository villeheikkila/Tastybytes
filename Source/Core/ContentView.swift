import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ContentView: View {
    var body: some View {
        EnvironmentProvider {
            SubscriptionProvider {
                DeviceInfoProvider {
                    SplashScreenProvider {
                        PhaseObserver {
                            AppStateObserver {
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
