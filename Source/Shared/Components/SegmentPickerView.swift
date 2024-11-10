import SwiftUI

protocol SegmentPickerItem: Equatable, Identifiable, CaseIterable {
    var label: String { get }
}

struct SegmentPickerView<Tab: SegmentPickerItem>: View where Tab.AllCases: RandomAccessCollection {
    @State var offset: CGFloat = 0
    @Binding var currentTab: Tab

    var tabs: [Tab] {
        Array(Tab.allCases)
    }

    var tabCount: Int {
        tabs.count
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    Text(tab.label)
                        .fontWeight(.semibold)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                }
            }
            .frame(height: 35)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.thinMaterial)
                    .overlay(alignment: .leading) {
                        HStack(spacing: 0) {
                            ForEach(tabs) { tab in
                                Text(tab.label)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .contentShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            currentTab = tab
                                            offset = -(geometry.size.width) * CGFloat(indexOf(tab: tab))
                                        }
                                    }
                            }
                        }
                        .offset(x: -tabOffset(size: geometry.size))
                        .frame(width: geometry.size.width)
                    }
                    .frame(width: geometry.size.width / CGFloat(tabCount))
                    .mask {
                        RoundedRectangle(cornerRadius: 8)
                    }
                    .offset(x: tabOffset(size: geometry.size))
            }
            .frame(width: geometry.size.width)
        }
    }

    private func indexOf(tab: Tab) -> Int {
        Array(Tab.allCases).firstIndex(where: { $0.id == tab.id }) ?? 0
    }

    private func tabOffset(size: CGSize) -> CGFloat {
        let index = indexOf(tab: currentTab)
        let buttonWidth = size.width / CGFloat(tabCount)
        return buttonWidth * CGFloat(index)
    }
}
