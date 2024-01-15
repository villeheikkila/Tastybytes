import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInScreen: View {
    enum Focusable {
        case checkInComment
    }

    private let logger = Logger(category: "CheckInScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @FocusState private var focusedField: Focusable?
    @State private var checkIn: CheckIn
    @State private var checkInComments = [CheckInComment]()
    @State private var showDeleteConfirmation = false
    @State private var showEditCommentPrompt = false
    @State private var deleteAsCheckInCommentAsModerator: CheckInComment? {
        didSet {
            if deleteAsCheckInCommentAsModerator != nil {
                showDeleteCommentAsModeratorConfirmation = true
            }
        }
    }

    @State private var toDeleteCheckInAsModerator: CheckIn? {
        didSet {
            if toDeleteCheckInAsModerator != nil {
                showDeleteCheckInAsModeratorConfirmation = true
            }
        }
    }

    @State private var showDeleteCheckInAsModeratorConfirmation = false
    @State private var showDeleteCommentAsModeratorConfirmation = false
    @State private var commentText = ""
    @State private var editCommentText = ""
    @State private var editComment: CheckInComment? {
        didSet {
            showEditCommentPrompt.toggle()
            editCommentText = editComment?.content ?? ""
        }
    }

    @State private var alertError: AlertError?
    // Refresh status
    @State private var refreshId = 0
    @State private var resultId: Int?

    var orderedCheckInComments: [CheckInComment] {
        checkInComments.reversed()
    }

    init(checkIn: CheckIn) {
        _checkIn = State(wrappedValue: checkIn)
    }

    var body: some View {
        List {
            CheckInCard(checkIn: checkIn, loadedFrom: .checkIn)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                .checkInContextMenu(
                    router: router,
                    profileEnvironmentModel: profileEnvironmentModel,
                    checkIn: checkIn,
                    onCheckInUpdate: { checkIn in
                        self.checkIn = checkIn
                    },
                    onDelete: { _ in
                        showDeleteConfirmation = true
                    }
                )
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
            commentSection
            Spacer()
                .frame(height: 200)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .refreshable {
            refreshId += 1
        }
        .overlay(
            MaterialOverlay(alignment: .bottom) {
                leaveCommentSection
            }
        )
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .confirmationDialog(
            "check-in.delete-confirmation.title",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            presenting: checkIn
        ) { presenting in
            ProgressButton(
                "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
                role: .destructive,
                action: { await deleteCheckIn(presenting) }
            )
        }
        .confirmationDialog(
            "Are you sure you want to delete comment as a moderator?",
            isPresented: $showDeleteCommentAsModeratorConfirmation,
            titleVisibility: .visible,
            presenting: deleteAsCheckInCommentAsModerator
        ) { presenting in
            ProgressButton(
                "Delete comment from \(presenting.profile.preferredName)",
                role: .destructive,
                action: { await deleteCommentAsModerator(presenting) }
            )
        }
        .confirmationDialog(
            "Are you sure you want to delete check-in as a moderator?",
            isPresented: $showDeleteCheckInAsModeratorConfirmation,
            titleVisibility: .visible,
            presenting: toDeleteCheckInAsModerator
        ) { presenting in
            ProgressButton(
                "Delete check-in from \(presenting.profile.preferredName)",
                role: .destructive,
                action: { await deleteCheckInAsModerator(presenting) }
            )
        }
        .task(id: refreshId) { [refreshId] in
            guard refreshId != resultId else { return }
            logger.info("Refreshing check-in screen with id: \(refreshId)")
            await loadCheckInData()
            resultId = refreshId
        }
    }

    func loadCheckInData() async {
        async let checkInPromise = repository.checkIn.getById(id: checkIn.id)
        async let checkInCommentPromise = repository.checkInComment.getByCheckInId(id: checkIn.id)
        async let summaryPromise: Void = notificationEnvironmentModel.markCheckInAsRead(
            checkIn: checkIn)

        let (checkInResult, checkInCommentResult, _) = await (
            checkInPromise,
            checkInCommentPromise,
            summaryPromise
        )

        switch checkInResult {
        case let .success(checkIn):
            withAnimation {
                self.checkIn = checkIn
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load check-in. Error: \(error) (\(#file):\(#line))")
        }

        switch checkInCommentResult {
        case let .success(checkInComments):
            withAnimation {
                self.checkInComments = checkInComments
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load check-in comments'. Error: \(error) (\(#file):\(#line))")
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            CheckInShareLinkView(checkIn: checkIn)
            Menu {
                if checkIn.profile.id == profileEnvironmentModel.id {
                    ControlGroup {
                        CheckInShareLinkView(checkIn: checkIn)
                        RouterLink(
                            "Edit", systemImage: "pencil",
                            sheet: .checkIn(
                                checkIn,
                                onUpdate: { updatedCheckIn in
                                    checkIn = updatedCheckIn
                                }
                            ),
                            useRootSheetManager: true
                        )
                        Button(
                            "Delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { showDeleteConfirmation = true }
                        )
                    }
                }
                Divider()
                RouterLink(
                    "Open Brand Owner",
                    systemImage: "network",
                    screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
                RouterLink(
                    "Open Brand", systemImage: "cart", screen: .fetchBrand(checkIn.product.subBrand.brand)
                )
                RouterLink(
                    "Open Sub-brand",
                    systemImage: "cart",
                    screen: .fetchSubBrand(checkIn.product.subBrand)
                )
                Divider()
                if profileEnvironmentModel.id != checkIn.profile.id {
                    ReportButton(entity: .checkIn(checkIn))
                }
                if profileEnvironmentModel.hasRole(.moderator) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canDeleteCheckInsAsModerator) {
                            Button("Delete as Moderator", systemImage: "trash.fill", role: .destructive) {
                                toDeleteCheckInAsModerator = checkIn
                            }
                        }
                    } label: {
                        Label("Moderation", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            } label: {
                Label("Options menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }

    private var commentSection: some View {
        ForEach(orderedCheckInComments) { comment in
            CheckInCommentView(comment: comment)
                .listRowSeparator(.hidden)
                .contextMenu {
                    if comment.profile == profileEnvironmentModel.profile {
                        Button("Edit", systemImage: "pencil") {
                            withAnimation {
                                editComment = comment
                            }
                        }
                        ProgressButton("Delete", systemImage: "trash.fill", role: .destructive) {
                            await deleteComment(comment)
                        }
                    } else {
                        ReportButton(entity: .comment(comment))
                    }
                    Divider()
                    if profileEnvironmentModel.hasRole(.moderator) {
                        Menu {
                            if profileEnvironmentModel.hasPermission(.canDeleteComments) {
                                Button("Delete as Moderator", systemImage: "trash.fill", role: .destructive) {
                                    deleteAsCheckInCommentAsModerator = comment
                                }
                            }
                        } label: {
                            Label("Moderation", systemImage: "gear")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
        }
        .alert(
            "Edit Comment", isPresented: $showEditCommentPrompt,
            actions: {
                TextField("TextField", text: $editCommentText)
                Button("actions.cancel", role: .cancel, action: {})
                ProgressButton(
                    "Edit",
                    action: {
                        await updateComment()
                    }
                )
            }
        )
    }

    private var leaveCommentSection: some View {
        HStack {
            TextField("Leave a comment!", text: $commentText)
                .focused($focusedField, equals: .checkInComment)
            ProgressButton(
                "Send the comment", systemImage: "paperplane.fill", action: { await sendComment() }
            )
            .labelStyle(.iconOnly)
            .disabled(isInvalidComment())
        }
        .padding(2)
    }

    func isInvalidComment() -> Bool {
        commentText.isEmpty
    }

    @MainActor
    func deleteCheckIn(_ checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete check-in. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updateComment() async {
        guard let editComment else { return }
        let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
        switch await repository.checkInComment.update(updateCheckInComment: updatedComment) {
        case let .success(updatedComment):
            guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else {
                return
            }
            withAnimation {
                checkInComments[index] = updatedComment
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to update comment \(editComment.id)'. Error: \(error) (\(#file):\(#line))")
        }
        editCommentText = ""
    }

    func deleteComment(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteById(id: comment.id) {
        case .success:
            withAnimation {
                checkInComments.remove(object: comment)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete comment '\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCommentAsModerator(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteAsModerator(comment: comment) {
        case .success:
            withAnimation {
                checkInComments.remove(object: comment)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to delete comment as moderator'\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    @MainActor
    func deleteCheckInAsModerator(_ checkIn: CheckIn) async {
        switch await repository.checkIn.deleteAsModerator(checkIn: checkIn) {
        case .success:
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to delete check-in as moderator'\(checkIn.id)'. Error: \(error) (\(#file):\(#line))"
            )
        }
    }

    func sendComment() async {
        let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

        let result = await repository.checkInComment.insert(newCheckInComment: newCheckInComment)
        switch result {
        case let .success(newCheckInComment):
            withAnimation {
                checkInComments.append(newCheckInComment)
            }
            commentText = ""
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to send comment. Error: \(error) (\(#file):\(#line))")
        }
    }
}
