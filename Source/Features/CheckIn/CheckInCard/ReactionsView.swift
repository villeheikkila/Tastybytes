import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ReactionsView: View {
    private let logger = Logger(category: "ReactionsView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var checkInReactions = [CheckInReaction]()
    @State private var isLoading = false
    @State private var task: Task<Void, Never>?

    let checkIn: CheckIn

    init(checkIn: CheckIn) {
        self.checkIn = checkIn
        _checkInReactions = State(initialValue: checkIn.checkInReactions)
    }

    var currentlyUserHasReacted: Bool {
        checkInReactions.contains(where: { $0.profile.id == profileEnvironmentModel.profile.id })
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            ForEach(checkInReactions) { reaction in
                Avatar(profile: reaction.profile)
                    .avatarSize(.medium)
                    .fixedSize()
            }
            Label("checkIn.reaction.react.label", systemImage: "hand.thumbsup")
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .symbolVariant(currentlyUserHasReacted ? .fill : .none)
                .foregroundColor(.yellow)
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    task = Task(priority: .userInitiated) {
                        await toggleReaction()
                    }
                }
                .allowsHitTesting(!isLoading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 24)
        .disabled(isLoading)
        .onDisappear {
            task?.cancel()
        }
        .sensoryFeedback(trigger: checkInReactions) { oldValue, newValue in
            newValue.count > oldValue.count ? .success : .impact(weight: .light)
        }
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
                logger.error("Removing check-in reaction \(reaction.id) failed. Error: \(error) (\(#file):\(#line))")
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
                router.open(.alert(.init()))
                logger.error("Adding check-in reaction for check-in \(checkIn.id) by \(profileEnvironmentModel.id) failed: \(error.localizedDescription)")
            }
        }
        isLoading = false
    }
}
