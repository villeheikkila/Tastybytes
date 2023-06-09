import SwiftUI
import Observation
import os

@Observable
final class SheetManager {
  private let logger = Logger(category: "SheetManager")
  var sheet: Sheet? = nil
  var nestedSheet: Sheet? = nil

  func navigate(sheet: Sheet) {
    if self.sheet != nil, nestedSheet != nil {
      logger.error("opening more than one nested sheet is not supported")
      return
    }
    if let currentSheetId = self.sheet?.id, sheet.id == currentSheetId {
      logger.warning("same sheet opened multiple times")
      return
    }
    if self.sheet != nil {
      nestedSheet = sheet
    } else {
      self.sheet = sheet
    }
  }
}
