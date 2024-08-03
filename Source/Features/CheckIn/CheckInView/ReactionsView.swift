import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ReactionsView: View {
    private let logger = Logger(category: "ReactionsView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @State private var checkInReactions = [CheckIn.Reaction.Saved]()
    @State private var isLoading = false
    @State private var task: Task<Void, Never>?

    let checkIn: CheckIn.Joined

    init(checkIn: CheckIn.Joined) {
        self.checkIn = checkIn
        _checkInReactions = State(initialValue: checkIn.checkInReactions)
    }

    var currentlyUserHasReacted: Bool {
        checkInReactions.contains(where: { $0.profile.id == profileModel.profile.id })
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            ForEach(checkInReactions) { reaction in
                RouterLink(open: .screen(.profile(reaction.profile))) {
                    AvatarView(profile: reaction.profile)
                        .avatarSize(.medium)
                        .fixedSize()
                }
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
                .allowsHitTesting(!isLoading && profileModel.hasPermission(.canReactToCheckIns))
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

    private func toggleReaction() async {
        isLoading = true
        if let reaction = checkInReactions.first(where: { $0.profile.id == profileModel.id }) {
            do {
                try await repository.checkInReactions.delete(id: reaction.id)
                withAnimation {
                    checkInReactions.remove(object: reaction)
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Removing check-in reaction \(reaction.id) failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            do {
                let checkInReaction = try await repository.checkInReactions.insert(id: checkIn.id)
                withAnimation {
                    checkInReactions.append(checkInReaction)
                }
            } catch {
                guard !error.isCancelled else { return }
                router.open(.alert(.init()))
                logger.error("Adding check-in reaction for check-in \(checkIn.id) by \(profileModel.id) failed: \(error.localizedDescription)")
            }
        }
        isLoading = false
    }
}
