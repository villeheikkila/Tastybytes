import Components
import SwiftUI

struct CheckInDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var checkInAt: Date
    @Binding var isLegacyCheckIn: Bool
    @Binding var isNostalgic: Bool

    var body: some View {
        Form {
            Group {
                DatePicker("checkIn.datePicker.label", selection: $checkInAt, in: ...Date.now)
                    .datePickerStyle(.graphical)
                    .disabled(isLegacyCheckIn)
                Toggle("checkIn.datePicker.markAsLegacy.label", isOn: $isLegacyCheckIn)
                Toggle("checkIn.datePicker.markAsNostalgic.label", isOn: $isNostalgic)
            }
            .customListRowBackground()
        }
        .proMembershipOverlay()
        .scrollContentBackground(.hidden)
        .navigationTitle("checkIn.datePicker.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}

extension View {
    func proMembershipOverlay() -> some View {
        modifier(ProMembershipOverlayModifier())
    }
}

struct ProMembershipOverlayModifier: ViewModifier {
    @Environment(SubscriptionModel.self) private var subscriptionModel

    private var isEnabled: Bool {
        subscriptionModel.isProMember
    }

    func body(content: Content) -> some View {
        content
            .disabled(isEnabled)
            .overlay(
                Group {
                    if isEnabled {
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .opacity(0.7)
                                .blur(radius: 30)
                                .allowsHitTesting(false)
                                .ignoresSafeArea()

                            ContentUnavailableView(label: {
                                VStack {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundStyle(.yellow)
                                    Text("Unlock Pro Membership")
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                }
                            }, description: {
                                Text("Unlock check-in date modification and many other features by becoming a Pro member")
                            }, actions: {
                                RouterLink(open: .sheet(.subscribe)) {
                                    Text("Subscribe Now")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            })
                        }
                    }
                }
            )
            .scrollDisabled(isEnabled)
    }
}
