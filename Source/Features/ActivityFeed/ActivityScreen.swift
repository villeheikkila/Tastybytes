import SwiftUI

struct ActivityTab: View {
    @Environment(CheckInModel.self) private var checkInModel

    var body: some View {
        @Bindable var checkInModel = checkInModel
        ActivityListView(segment: checkInModel.segment)
        .tabViewStyle(.tabBarOnly)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SegmentPickerView(currentTab: $checkInModel.segment, width: 300)
            }
        }
        .navigationTitle("tab.activity")
        .toolbarVisibility(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}
