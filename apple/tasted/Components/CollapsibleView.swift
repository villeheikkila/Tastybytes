import SwiftUI

struct CollapsibleView<Content: View, ListItem: View>: View {
    @State var content: () -> ListItem
    @State var expandedContent: () -> Content

    @State private var collapsed: Bool = true

    var body: some View {
        VStack {
            HStack {
                self.content()
                Spacer()
                Button(
                    action: {
                        self.collapsed.toggle()
                    },
                    label: {
                        HStack {
                            Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                        }
                        .padding(.bottom, 1)
                        .background(Color.primary.opacity(0.01))
                    }
                )
                .buttonStyle(PlainButtonStyle())
            }

            VStack {
                self.expandedContent()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .animation(.easeOut)
            .transition(.slide)
        }
    }
}

