import SwiftUI

#if canImport(_Translation_SwiftUI)
    import Translation

    extension View {
        func translateText(isPresented: Binding<Bool>, text: String) -> some View {
            translationPresentation(isPresented: isPresented, text: text)
        }
    }
#else
    extension View {
        func translateText(isPresented _: Binding<Bool>, text _: String) -> some View {
            self
        }
    }
#endif
