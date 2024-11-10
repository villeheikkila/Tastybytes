import SwiftUI

struct ActivityScreen: View {
    @Environment(CheckInModel.self) private var checkInModel

    var body: some View {
        @Bindable var checkInModel = checkInModel
        TabView(selection: $checkInModel.segment) {
            ForEach(ActivitySegment.allCases) { segment in
                segment.tab
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .toolbar {
            ToolbarItem(placement: .principal) {
                SegmentPickerView(currentTab: $checkInModel.segment, width: 300)
            }
        }
        .navigationTitle("tab.activity")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await checkInModel.listenToCheckInImageUploads()
        }
    }
}
