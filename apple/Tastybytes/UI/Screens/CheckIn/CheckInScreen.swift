import OSLog
import SwiftUI

struct CheckInScreen: View {
    enum Focusable {
        case checkInComment
    }

    private let logger = Logger(category: "CheckInScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
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
    
    var orderedCheckInComments: [CheckInComment] {
        checkInComments.reversed()
    }

    init(checkIn: CheckIn) {
        _checkIn = State(wrappedValue: checkIn)
    }

    var body: some View {
        List {
            CheckInCardView(checkIn: checkIn, loadedFrom: .checkIn)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                .contextMenu {
                    menuContent
                }
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
        .overlay(
            MaterialOverlay(alignment: .bottom) {
                leaveCommentSection
            }
        )
        .toolbar {
            toolbarContent
        }
        .confirmationDialog("Are you sure you want to delete check-in? The data will be permanently lost.",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible,
                            presenting: checkIn)
        { presenting in
            ProgressButton(
                "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
                role: .destructive,
                action: { await deleteCheckIn(presenting) }
            )
        }
        .confirmationDialog("Are you sure you want to delete comment as a moderator?",
                            isPresented: $showDeleteCommentAsModeratorConfirmation,
                            titleVisibility: .visible,
                            presenting: deleteAsCheckInCommentAsModerator)
        { presenting in
            ProgressButton(
                "Delete comment from \(presenting.profile.preferredName)",
                role: .destructive,
                action: { await deleteCommentAsModerator(presenting) }
            )
        }
        .confirmationDialog("Are you sure you want to delete check-in as a moderator?",
                            isPresented: $showDeleteCheckInAsModeratorConfirmation,
                            titleVisibility: .visible,
                            presenting: toDeleteCheckInAsModerator)
        { presenting in
            ProgressButton(
                "Delete check-in from \(presenting.profile.preferredName)",
                role: .destructive,
                action: { await deleteCheckInAsModerator(presenting) }
            )
        }
        .task {
            await loadCheckInComments()
            await notificationManager.markCheckInAsRead(checkIn: checkIn)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                menuContent
            } label: {
                Label("Options menu", systemSymbol: .ellipsis)
                    .labelStyle(.iconOnly)
            }
        }
    }

    @ViewBuilder
    var menuContent: some View {
        CheckInShareLinkView(checkIn: checkIn)
        Divider()
        RouterLink(
            "Open Company",
            systemSymbol: .network,
            screen: .company(checkIn.product.subBrand.brand.brandOwner)
        )
        RouterLink("Open Product", systemSymbol: .grid, screen: .product(checkIn.product))
        RouterLink("Open Brand", systemSymbol: .cart, screen: .fetchBrand(checkIn.product.subBrand.brand))
        RouterLink(
            "Open Sub-brand",
            systemSymbol: .cart,
            screen: .fetchSubBrand(checkIn.product.subBrand)
        )

        if profileManager.id != checkIn.profile.id {
            ReportButton(entity: .checkIn(checkIn))
        }

        if checkIn.profile.id == profileManager.id {
            RouterLink("Edit", systemSymbol: .pencil, sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
                updateCheckIn(updatedCheckIn)
            }))
            Button("Delete", systemSymbol: .trashFill, role: .destructive, action: { showDeleteConfirmation = true })
        }

        Divider()
        if profileManager.hasRole(.moderator) {
            Menu {
                if profileManager.hasPermission(.canDeleteCheckInsAsModerator) {
                    Button("Delete as Moderator", systemSymbol: .trashFill, role: .destructive) {
                        toDeleteCheckInAsModerator = checkIn
                    }
                }
            } label: {
                Label("Moderation", systemSymbol: .gear)
                    .labelStyle(.iconOnly)
            }
        }
    }

    private var commentSection: some View {
        ForEach(orderedCheckInComments) { comment in
            CheckInCommentView(comment: comment)
                .listRowSeparator(.hidden)
                .contextMenu {
                    if comment.profile == profileManager.profile {
                        Button("Edit", systemSymbol: .pencil) {
                            withAnimation {
                                editComment = comment
                            }
                        }
                        ProgressButton("Delete", systemSymbol: .trashFill, role: .destructive) {
                            await deleteComment(comment)
                        }
                    } else {
                        ReportButton(entity: .comment(comment))
                    }
                    Divider()
                    if profileManager.hasRole(.moderator) {
                        Menu {
                            if profileManager.hasPermission(.canDeleteComments) {
                                Button("Delete as Moderator", systemSymbol: .trashFill, role: .destructive) {
                                    deleteAsCheckInCommentAsModerator = comment
                                }
                            }
                        } label: {
                            Label("Moderation", systemSymbol: .gear)
                                .labelStyle(.iconOnly)
                        }
                    }
                }
        }
        .alert("Edit Comment", isPresented: $showEditCommentPrompt, actions: {
            TextField("TextField", text: $editCommentText)
            Button("Cancel", role: .cancel, action: {})
            ProgressButton("Edit", action: {
                await updateComment()
            })
        })
    }

    private var leaveCommentSection: some View {
        HStack {
            TextField("Leave a comment!", text: $commentText)
                .focused($focusedField, equals: .checkInComment)
            ProgressButton("Send the comment", systemSymbol: .paperplaneFill, action: { await sendComment() })
                .labelStyle(.iconOnly)
                .disabled(isInvalidComment())
        }
        .padding(2)
    }

    func updateCheckIn(_ checkIn: CheckIn) {
        self.checkIn = checkIn
    }

    func isInvalidComment() -> Bool {
        commentText.isEmpty
    }

    func deleteCheckIn(_ checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            await MainActor.run {
                router.removeLast()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to delete check-in. error: \(error)")
        }
    }

    func loadCheckInComments() async {
        switch await repository.checkInComment.getByCheckInId(id: checkIn.id) {
        case let .success(checkIns):
            await MainActor.run {
                withAnimation {
                    checkInComments = checkIns
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to load check-in comments'. error: \(error)")
        }
    }

    func updateComment() async {
        guard let editComment else { return }
        let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
        switch await repository.checkInComment.update(updateCheckInComment: updatedComment) {
        case let .success(updatedComment):
            guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else { return }
            await MainActor.run {
                withAnimation {
                    checkInComments[index] = updatedComment
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to update comment \(editComment.id)'. error: \(error)")
        }
        editCommentText = ""
    }

    func deleteComment(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteById(id: comment.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    checkInComments.remove(object: comment)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to delete comment '\(comment.id)'. error: \(error)")
        }
    }

    func deleteCommentAsModerator(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteAsModerator(comment: comment) {
        case .success:
            await MainActor.run {
                withAnimation {
                    checkInComments.remove(object: comment)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to delete comment as moderator'\(comment.id)'. error: \(error)")
        }
    }

    func deleteCheckInAsModerator(_ checkIn: CheckIn) async {
        switch await repository.checkIn.deleteAsModerator(checkIn: checkIn) {
        case .success:
            await MainActor.run {
                router.removeLast()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to delete check-in as moderator'\(checkIn.id)'. error: \(error)")
        }
    }

    func sendComment() async {
        let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

        let result = await repository.checkInComment.insert(newCheckInComment: newCheckInComment)
        switch result {
        case let .success(newCheckInComment):
            await MainActor.run {
                withAnimation {
                    checkInComments.append(newCheckInComment)
                }
                commentText = ""
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to send comment. error: \(error)")
        }
    }
}
