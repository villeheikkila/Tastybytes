import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private var _window: UIWindow?

  func scene(_: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    let splitView = UISplitViewController()
    splitView.primaryBackgroundStyle = .sidebar
  }
}
