import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInScreen: View {
    private let logger = Logger(category: "CheckInScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @FocusState private var focusedField: CheckInLeaveComment.Focusable?
    @State private var showDeleteCheckInAsModeratorConfirmation = false
    @State private var sheet: Sheet?
    @State private var checkIn: CheckIn
    @State private var checkInComments = [CheckInComment]()
    @State private var showDeleteConfirmation = false

    @State private var toDeleteCheckInAsModerator: CheckIn? {
        didSet {
            if toDeleteCheckInAsModerator != nil {
                showDeleteCheckInAsModeratorConfirmation = true
            }
        }
    }

    @State private var alertError: AlertError?
    // Refresh status
    @State private var refreshId = 0
    @State private var resultId: Int?

    init(checkIn: CheckIn) {
        _checkIn = State(wrappedValue: checkIn)
    }

    var body: some View {
        List {
            header
                .onTapGesture {
                    focusedField = nil
                }
            ForEach(checkInComments) { comment in
                CheckInCommentRow(comment: comment, checkInComments: $checkInComments)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .refreshable {
            await loadCheckInData()
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing, content: {
            CheckInLeaveComment(checkIn: checkIn, checkInComments: $checkInComments, focusedField: _focusedField)
        })
        .toolbar {
            toolbarContent
        }
        .task(id: refreshId) { [refreshId] in
            guard refreshId != resultId else { return }
            logger.info("Refreshing check-in screen with id: \(refreshId)")
            await loadCheckInData()
            resultId = refreshId
        }
        .alertError($alertError)
        .confirmationDialog(
            "checkIn.delete.confirmation.title",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            presenting: checkIn
        ) { presenting in
            ProgressButton(
                "Delete \(presenting.product.formatted(.fullName)) check-in",
                role: .destructive,
                action: { await deleteCheckIn(presenting) }
            )
        }
        .confirmationDialog(
            "checkIn.delete.asModerator.title",
            isPresented: $showDeleteCheckInAsModeratorConfirmation,
            titleVisibility: .visible,
            presenting: toDeleteCheckInAsModerator
        ) { presenting in
            ProgressButton(
                "checkIn.delete.asModerator.label \(presenting.profile.preferredName)",
                role: .destructive,
                action: { await deleteCheckInAsModerator(presenting) }
            )
        }
    }

    private var header: some View {
        CheckInCard(checkIn: checkIn, loadedFrom: .checkIn)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
            .sheets(item: $sheet)
            .contextMenu {
                ControlGroup {
                    CheckInShareLinkView(checkIn: checkIn)
                    if checkIn.profile.id == profileEnvironmentModel.id {
                        Button(
                            "labels.edit",
                            systemImage: "pencil",
                            action: { sheet = .checkIn(checkIn, onUpdate: { updatedCheckIn in
                                checkIn = updatedCheckIn
                            })
                            }
                        )
                        Button(
                            "labels.delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: {
                                showDeleteConfirmation = true
                            }
                        )
                    } else {
                        Button(
                            "checkIn.add.label",
                            systemImage: "pencil",
                            action: { sheet = .newCheckIn(checkIn.product, onCreation: { checkIn in
                                router.navigate(screen: .checkIn(checkIn))
                            })
                            }
                        )
                        ReportButton(sheet: $sheet, entity: .checkIn(checkIn))
                    }
                }
                Divider()
                RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink(
                    "brand.screen.open",
                    systemImage: "cart",
                    screen: .fetchBrand(checkIn.product.subBrand.brand)
                )
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    screen: .fetchSubBrand(checkIn.product.subBrand)
                )
                if let location = checkIn.location {
                    RouterLink(
                        "checkIn.actions.openLocationScreen",
                        systemImage: "network",
                        screen: .location(location)
                    )
                }
                if let purchaseLocation = checkIn.purchaseLocation {
                    RouterLink(
                        "checkIn.actions.openPurchaseLocationScreen",
                        systemImage: "network",
                        screen: .location(purchaseLocation)
                    )
                }
                Divider()
            }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            CheckInShareLinkView(checkIn: checkIn)
            Menu {
                if checkIn.profile.id == profileEnvironmentModel.id {
                    ControlGroup {
                        CheckInShareLinkView(checkIn: checkIn)
                        Button(
                            "labels.edit", systemImage: "pencil",
                            action: { sheet = .checkIn(
                                checkIn,
                                onUpdate: { updatedCheckIn in
                                    checkIn = updatedCheckIn
                                }
                            )
                            }
                        )
                        Button(
                            "labels.delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { showDeleteConfirmation = true }
                        )
                    }
                }
                Divider()
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
                RouterLink(
                    "brand.screen.open", systemImage: "cart", screen: .fetchBrand(checkIn.product.subBrand.brand)
                )
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    screen: .fetchSubBrand(checkIn.product.subBrand)
                )
                Divider()
                if profileEnvironmentModel.id != checkIn.profile.id {
                    ReportButton(sheet: $sheet, entity: .checkIn(checkIn))
                }
                if profileEnvironmentModel.hasRole(.moderator) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canDeleteCheckInsAsModerator) {
                            Button("labels.delete.asModerator", systemImage: "trash.fill", role: .destructive) {
                                toDeleteCheckInAsModerator = checkIn
                            }
                        }
                    } label: {
                        Label("Moderation", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
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
            logger.error("Failed to load check-in comments. Error: \(error) (\(#file):\(#line))")
        }
    }

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

    func deleteCheckInAsModerator(_ checkIn: CheckIn) async {
        switch await repository.checkIn.deleteAsModerator(checkIn: checkIn) {
        case .success:
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete check-in as moderator'\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
