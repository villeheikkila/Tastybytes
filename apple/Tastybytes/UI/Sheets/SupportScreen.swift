import SwiftUI

struct SupportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var purchaseSuccessDisplayed = false
    @State private var purchaseErrorDisplayed = false

    var body: some View {
        List {
            Text("")
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))

            Spacer().listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            VStack(alignment: .leading, spacing: 30) {
                ForEach(features, id: \.self) { feature in
                    feature.view
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init())

            Spacer().listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            HStack {
                Spacer()
                ProgressButton(action: {}, label: {
                    Text("0,99€ a month")
                        .font(.headline)
                        .padding(.all, 8)
                }).buttonStyle(ScalingButton())
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Become a supporter")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }

    let features: [FeatureItem] = [FeatureItem(
        title: "Precise Ratings",
        description: "Rate check-ins using increments of 0.25",
        systemSymbol: .starLeadinghalfFilled,
        color: .yellow
    ),
    FeatureItem(
        title: "Change Date",
        description: "Gain ability to change the date of your check-ins",
        systemSymbol: .calendarBadgePlus,
        color: .blue
    ),
    FeatureItem(
        title: "Nostalgic Tag",
        description: "Mark your check-ins as nostalgic",
        systemSymbol: .heartTextSquare,
        color: .pink
    )]
}
