import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ReactionsView: View {
    private let logger = Logger(category: "ReactionsView")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var checkInReactions = [CheckInReaction]()
    @State private var isLoading = false
    @State private var alertError: AlertError?
    @State private var task: Task<Void, Never>?

    let checkIn: CheckIn

    private let size: Double = 24

    init(checkIn: CheckIn) {
        self.checkIn = checkIn
        _checkInReactions = State(initialValue: checkIn.checkInReactions)
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            ForEach(checkInReactions) { reaction in
                Avatar(profile: reaction.profile, size: size)
            }
            Label(
                "React to check-in",
                systemImage: "hand.thumbsup"
            )
            .labelStyle(.iconOnly)
            .symbolVariant(hasReacted(profileEnvironmentModel.profile) ? .fill : .none)
            .imageScale(.large)
            .foregroundColor(Color(.systemYellow))
        }
        .frame(maxWidth: 80, minHeight: size + 4)
        .contentShape(Rectangle())
        .alertError($alertError)

        .accessibilityAddTraits(.isButton)
        .allowsHitTesting(!isLoading)
        .onTapGesture {
            task = Task(priority: .userInitiated) {
                await toggleReaction()
            }
        }
        .disabled(isLoading)
        .onDisappear {
            task?.cancel()
        }
        .sensoryFeedback(trigger: checkInReactions) { oldValue, newValue in
            newValue.count > oldValue.count ? .success : .impact(weight: .light)
        }
    }

    func hasReacted(_ profile: Profile) -> Bool {
        checkInReactions.contains(where: { $0.profile.id == profile.id })
    }

    func toggleReaction() async {
        isLoading = true
        if let reaction = checkInReactions.first(where: { $0.profile.id == profileEnvironmentModel.id }) {
            switch await repository.checkInReactions.delete(id: reaction.id) {
            case .success:
                withAnimation {
                    checkInReactions.remove(object: reaction)
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("removing check-in reaction \(reaction.id) failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.checkInReactions
                .insert(newCheckInReaction: CheckInReaction.NewRequest(checkInId: checkIn.id))
            {
            case let .success(checkInReaction):
                withAnimation {
                    checkInReactions.append(checkInReaction)
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                alertError = .init()
                logger
                    .error(
                        "adding check-in reaction for check-in \(checkIn.id) by \(profileEnvironmentModel.id) failed: \(error.localizedDescription)"
                    )
            }
        }
        isLoading = false
    }
}
