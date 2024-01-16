import Components
import SwiftUI

@MainActor
struct SheetLink<LabelView: View>: View {
    @Environment(Router.self) private var router
    @Environment(SheetManager.self) private var sheetManager
    @State private var activeSheet: Sheet?

    let sheet: Sheet
    @Binding var sheets: Sheet?

    let asTapGesture: Bool
    let initializeSheets: Bool
    let label: LabelView

    var body: some View {
        if asTapGesture {
            label
                .accessibilityAddTraits(.isLink)
                .contentShape(Rectangle())
                .onTapGesture {
                    openSheet(sheet: sheet)
                }
                .sheets(item: $activeSheet)
        } else {
            Button(action: { openSheet(sheet: sheet)
            }, label: { label })
                .sheets(item: $activeSheet)
        }
    }

    func openSheet(sheet: Sheet) {
        if initializeSheets {
            sheetManager.navigate(sheet: sheet)
        } else {
            activeSheet = sheet
        }
    }
}
