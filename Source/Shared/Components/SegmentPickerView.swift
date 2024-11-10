import SwiftUI

protocol SegmentPickerItem: Equatable, Identifiable, CaseIterable {
    var label: String { get }
}

struct SegmentPickerView<Tab: SegmentPickerItem>: View where Tab.AllCases: RandomAccessCollection {
    @State var offset: CGFloat = 0
    @Binding var currentTab: Tab
    let width: CGFloat

    var tabs: [Tab] {
        Array(Tab.allCases)
    }

    var tabCount: Int {
        tabs.count
    }

    var body: some View {
        let segmentShape = RoundedRectangle(cornerRadius: 8)

        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                Text(tab.label)
                    .fontWeight(.semibold)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
            }
        }
        .frame(width: width)
        .overlay(alignment: .leading) {
            segmentShape
                .fill(.thinMaterial)
                .overlay(alignment: .leading) {
                    HStack(spacing: 0) {
                        ForEach(tabs) { tab in
                            Text(tab.label)
                                .fontWeight(.semibold)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .contentShape(segmentShape)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        currentTab = tab
                                        offset = -width * CGFloat(indexOf(tab: tab))
                                    }
                                }
                        }
                    }
                    .offset(x: -segmentOffset())
                    .frame(width: width)
                }
                .frame(width: width / CGFloat(tabCount))
                .mask {
                    segmentShape
                }
                .offset(x: segmentOffset())
        }
    }

    private func indexOf(tab: Tab) -> Int {
        tabs.firstIndex(where: { $0.id == tab.id }) ?? 0
    }

    private func segmentOffset() -> CGFloat {
        let index = indexOf(tab: currentTab)
        let buttonWidth = width / CGFloat(tabCount)
        return buttonWidth * CGFloat(index)
    }
}
