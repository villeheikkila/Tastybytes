import AlertToast
import SwiftUI

class ToastManager: ObservableObject {
  @Published var show = false
  @Published var toast = AlertToast(type: .regular, title: "") {
    didSet {
      show.toggle()
    }
  }

  func toggle(_ type: ToastType) {
    DispatchQueue.main.async {
      switch type {
      case let .success(title):
        self.toast = AlertToast(type: .complete(.green), title: title)
      case let .error(title):
        self.toast = AlertToast(type: .error(.red), title: title)
      }
    }
  }
}

enum ToastType {
  case success(_ title: String)
  case error(_ title: String)
}
