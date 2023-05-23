import SwiftUI

@MainActor
final class SheetManager: ObservableObject {
  private let logger = getLogger(category: "SheetManager")
  @Published var sheet: Sheet?
  @Published var nestedSheet: Sheet?

  func navigate(sheet: Sheet) {
    if self.sheet != nil, nestedSheet != nil {
      logger.error("opening more than one nested sheet is not supported")
      return
    }
    if self.sheet != nil {
      nestedSheet = sheet
    } else {
      self.sheet = sheet
    }
  }
}
