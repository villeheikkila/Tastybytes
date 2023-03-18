import AlertToast
import SwiftUI

@MainActor class ToastManager: ObservableObject {
  enum ToastType {
    case success(_ title: String)
    case error(_ title: String)
  }

  @Published var show = false
  @Published var toast = AlertToast(type: .regular, title: "") {
    didSet {
      show.toggle()
    }
  }

  func toggle(_ type: ToastType) {
    switch type {
    case let .success(title):
      toast = AlertToast(type: .complete(.green), title: title)
    case let .error(title):
      toast = AlertToast(type: .error(.red), title: title)
    }
  }
}
