import SwiftUI
import Observation
import OSLog

@Observable
final class SheetManager {
  private let logger = Logger(category: "SheetManager")
  var sheet: Sheet? = nil
  var nestedSheet: Sheet? = nil

  func navigate(sheet: Sheet) {
    if self.sheet != nil, nestedSheet != nil {
      logger.error("Opening more than one nested sheet is not supported")
      return
    }
    if let currentSheetId = self.sheet?.id, sheet.id == currentSheetId {
      logger.error("Same sheet opened multiple times (\(#file):\(#line))")
      return
    }
    if self.sheet != nil {
      nestedSheet = sheet
    } else {
      self.sheet = sheet
    }
  }
}
