import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

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

    init(checkIn: CheckIn) {
        _checkIn = State(wrappedValue: checkIn)
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                if state == .populated {
                    content
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .checkInCardLoadedFrom(.checkIn)
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
                if state == .populated {
                    CheckInLeaveComment(checkIn: checkIn, checkInComments: $checkInComments, focusedField: _focusedField, onSubmitted: { comment in
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        scrollProxy.scrollTo(comment.id, anchor: .top)
                    })
                }
            })
            .toolbar {
                toolbarContent
            }
            .initialTask {
                await loadCheckInData()
            }
        }
    }

    @ViewBuilder private var content: some View {
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
            CheckInCommentRowView(checkIn: checkIn, comment: comment, checkInComments: $checkInComments)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                .id(comment.id)
        }
    }

    private var header: some View {
        CheckInCard(checkIn: checkIn, onDeleteImage: { deletedImageEntity in
            checkIn = checkIn.copyWith(images: checkIn.images.removing(deletedImageEntity))
        })
        .contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileEnvironmentModel.id {
                    RouterLink(
                        "labels.edit",
                        systemImage: "pencil",
                        open: .sheet(.checkIn(.update(checkIn: checkIn, onUpdate: { updatedCheckIn in
                            checkIn = updatedCheckIn
                        })))
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
                    RouterLink(
                        "checkIn.add.label",
                        systemImage: "pencil",
                        open: .sheet(.checkIn(.create(product: checkIn.product, onCreation: { checkIn in
                            router.open(.screen(.checkIn(checkIn)))
                        })))
                    )
                }
            }
            Divider()
            RouterLink("product.screen.open", systemImage: "grid", open: .screen(.product(checkIn.product)))
            RouterLink(
                "company.screen.open",
                systemImage: "network",
                open: .screen(.company(checkIn.product.subBrand.brand.brandOwner))
            )
            RouterLink(
                "brand.screen.open",
                systemImage: "cart",
                open: .screen(.fetchBrand(checkIn.product.subBrand.brand))
            )
            RouterLink(
                "subBrand.screen.open",
                systemImage: "cart",
                open: .screen(.subBrand(checkIn.product.subBrand))
            )
            if let location = checkIn.location {
                RouterLink(
                    "location.open",
                    systemImage: "network",
                    open: .screen(.location(location))
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "location.open.purchaseLocation",
                    systemImage: "network",
                    open: .screen(.location(purchaseLocation))
                )
            }
            Divider()
            ReportButton(entity: .checkIn(checkIn))
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                if checkIn.profile.id == profileEnvironmentModel.id {
                    ControlGroup {
                        CheckInShareLinkView(checkIn: checkIn)
                        RouterLink(
                            "labels.edit", systemImage: "pencil",
                            open: .sheet(.checkIn(.update(checkIn:
                                checkIn,
                                onUpdate: { updatedCheckIn in
                                    checkIn = updatedCheckIn
                                })
                            ))
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
                    open: .screen(.company(checkIn.product.subBrand.brand.brandOwner))
                )
                RouterLink("product.screen.open", systemImage: "grid", open: .screen(.product(checkIn.product)))
                RouterLink(
                    "brand.screen.open", systemImage: "cart", open: .screen(.fetchBrand(checkIn.product.subBrand.brand))
                )
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    open: .screen(.subBrand(checkIn.product.subBrand))
                )
                Divider()
                ReportButton(entity: .checkIn(checkIn))
                Divider()
                AdminRouterLink(open: .sheet(.checkInAdmin(checkIn: checkIn, onDelete: {
                    router.removeLast()
                })))
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
                AsyncButton(
                    "checkIn.delete.confirmation.label \(presenting.product.formatted(.fullName))",
                    role: .destructive,
                    action: { await deleteCheckIn(presenting) }
                )
            }
        }
    }

    func loadCheckInData(withHaptics: Bool = false) async {
        async let checkInPromise = repository.checkIn.getById(id: checkIn.id)
        async let checkInCommentPromise = repository.checkInComment.getByCheckInId(id: checkIn.id)
        async let markCheckInAsReadPromise: Void = notificationEnvironmentModel.markCheckInAsRead(
            checkIn: checkIn)
        var errors = [Error]()
        do {
            let (checkInResult, checkInCommentResult, _) = try await (
                checkInPromise,
                checkInCommentPromise,
                markCheckInAsReadPromise
            )
            withAnimation {
                checkIn = checkInResult
                checkInComments = checkInCommentResult
            }
        } catch {
            errors.append(error)
            logger.error("Failed to load check-in screen. Error: \(error) (\(#file):\(#line))")
        }
        state = .getState(errors: errors, withHaptics: withHaptics, feedbackEnvironmentModel: feedbackEnvironmentModel)
    }

    func deleteCheckIn(_ checkIn: CheckIn) async {
        do {
            try await repository.checkIn.delete(id: checkIn.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.removeLast()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete check-in. Error: \(error) (\(#file):\(#line))")
        }
    }
}
