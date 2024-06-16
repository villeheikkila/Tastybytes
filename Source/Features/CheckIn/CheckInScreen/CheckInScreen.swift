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
    @State private var state: ScreenState = .loading
    @State private var checkIn: CheckIn
    @State private var checkInComments = [CheckInComment]()
    @State private var showDeleteConfirmation = false
    @State private var toDeleteCheckInAsModerator: CheckIn?
    @State private var alertError: AlertError?

    init(checkIn: CheckIn) {
        _checkIn = State(wrappedValue: checkIn)
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                if state == .populated {
                    populatedContent
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .overlay {
                ScreenStateOverlayView(state: state, errorDescription: "checkIn.screen.failedToLoad \(checkIn.product.formatted(.fullName)) \(checkIn.profile.preferredName)", errorAction: {
                    await loadCheckInData(withHaptics: true)
                })
            }
            .contentMargins(.bottom, 100)
            .refreshable {
                await loadCheckInData(withHaptics: true)
            }
            .safeAreaInset(edge: .bottom, alignment: .trailing, content: {
                CheckInLeaveComment(checkIn: checkIn, checkInComments: $checkInComments, focusedField: _focusedField, onSubmitted: { comment in
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    scrollProxy.scrollTo(comment.id, anchor: .top)
                })
            })
            .toolbar {
                toolbarContent
            }
            .initialTask {
                await loadCheckInData()
            }
            .alertError($alertError)
        }
    }

    @ViewBuilder private var populatedContent: some View {
        header
            .id(0)
            .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
            .listRowSeparator(.visible, edges: .bottom)
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -50
            }
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                focusedField = nil
            }
        ForEach(checkInComments) { comment in
            CheckInCommentRow(checkIn: checkIn, comment: comment, checkInComments: $checkInComments)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                .id(comment.id)
        }
    }

    private var header: some View {
        CheckInCard(checkIn: checkIn, loadedFrom: .checkIn, onDeleteImage: { deletedImageEntity in
            checkIn = checkIn.copyWith(images: checkIn.images.removing(deletedImageEntity))
        })
        .contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileEnvironmentModel.id {
                    Button(
                        "labels.edit",
                        systemImage: "pencil",
                        action: { router.openRootSheet(.checkIn(.update(checkIn: checkIn, onUpdate: { updatedCheckIn in
                            checkIn = updatedCheckIn
                        })))
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
                        action: { router.openRootSheet(.checkIn(.create(product: checkIn.product, onCreation: { checkIn in
                            router.navigate(screen: .checkIn(checkIn))
                        })))
                        }
                    )
                    ReportButton(entity: .checkIn(checkIn))
                }
            }
            Divider()
            RouterLink("product.screen.open", systemImage: "grid", screen: .product(checkIn.product))
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
                    "location.open",
                    systemImage: "network",
                    screen: .location(location)
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "location.open.purchaseLocation",
                    systemImage: "network",
                    screen: .location(purchaseLocation)
                )
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                if checkIn.profile.id == profileEnvironmentModel.id {
                    ControlGroup {
                        CheckInShareLinkView(checkIn: checkIn)
                        Button(
                            "labels.edit", systemImage: "pencil",
                            action: { router.openRootSheet(.checkIn(.update(checkIn:
                                checkIn,
                                onUpdate: { updatedCheckIn in
                                    checkIn = updatedCheckIn
                                })
                            ))
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
                RouterLink("product.screen.open", systemImage: "grid", screen: .product(checkIn.product))
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
                    ReportButton(entity: .checkIn(checkIn))
                }
                if profileEnvironmentModel.hasRole(.moderator) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canDeleteCheckInsAsModerator) {
                            Button("labels.delete.asModerator", systemImage: "trash.fill", role: .destructive) {
                                toDeleteCheckInAsModerator = checkIn
                            }
                        }
                    } label: {
                        Label("labels.moderation", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
            .confirmationDialog(
                "checkIn.delete.confirmation.title",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible,
                presenting: checkIn
            ) { presenting in
                ProgressButton(
                    "checkIn.delete.confirmation.label \(presenting.product.formatted(.fullName))",
                    role: .destructive,
                    action: { await deleteCheckIn(presenting) }
                )
            }
            .confirmationDialog(
                "checkIn.delete.asModerator.title",
                isPresented: $toDeleteCheckInAsModerator.isNotNull(),
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
    }

    func loadCheckInData(withHaptics: Bool = false) async {
        async let checkInPromise = repository.checkIn.getById(id: checkIn.id)
        async let checkInCommentPromise = repository.checkInComment.getByCheckInId(id: checkIn.id)
        async let summaryPromise: Void = notificationEnvironmentModel.markCheckInAsRead(
            checkIn: checkIn)

        let (checkInResult, checkInCommentResult, _) = await (
            checkInPromise,
            checkInCommentPromise,
            summaryPromise
        )

        var errors = [Error]()
        switch checkInResult {
        case let .success(checkIn):
            withAnimation {
                self.checkIn = checkIn
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load check-in. Error: \(error) (\(#file):\(#line))")
        }

        switch checkInCommentResult {
        case let .success(checkInComments):
            withAnimation {
                self.checkInComments = checkInComments
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load check-in comments. Error: \(error) (\(#file):\(#line))")
        }

        state = .getState(errors: errors, withHaptics: withHaptics, feedbackEnvironmentModel: feedbackEnvironmentModel)
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
