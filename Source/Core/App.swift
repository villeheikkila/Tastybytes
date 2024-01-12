import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@main
struct MainApp: App {
    private let logger = Logger(category: "Main")
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
