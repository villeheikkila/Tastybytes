import Components

import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct CheckInScreen: View {
    private let logger = Logger(label: "CheckInScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(NotificationModel.self) private var notificationModel
    @Environment(ProfileModel.self) private var profileModel
    @Environment(FeedbackModel.self) private var feedbackModel
    @FocusState private var focusedField: CheckInLeaveComment.Focusable?
    @State private var state: ScreenState = .loading
    @State private var checkIn = CheckIn.Joined()
    @State private var checkInComments = [CheckIn.Comment.Saved]()
    @State private var showDeleteConfirmation = false

    let id: CheckIn.Id

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                if state.isPopulated {
                    content
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .checkInLoadedFrom(.checkIn)
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
                if state.isPopulated, profileModel.hasPermission(.canCommentOnCheckIns) {
                    CheckInLeaveComment(checkIn: checkIn, checkInComments: $checkInComments, focusedField: _focusedField, onSubmitted: { comment in
                        try? await Task.sleep(for: .milliseconds(100))
                        scrollProxy.scrollTo(comment.id, anchor: .top)
                    })
                }
            })
            .toolbar {
                if state.isPopulated {
                    toolbarContent
                }
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
        CheckInView(checkIn: checkIn, onDeleteImage: { id in
            checkIn = checkIn.copyWith(images: checkIn.images.removingWithId(id))
        })
        .contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileModel.id {
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
                        open: .sheet(.checkIn(.create(product: checkIn.product, onCreation: { _ in
                            router.open(.screen(.checkIn(id)))
                        })))
                    )
                }
            }
            Divider()
            RouterLink("product.screen.open", systemImage: "grid", open: .screen(.product(checkIn.product.id)))
            RouterLink(
                "company.screen.open",
                systemImage: "network",
                open: .screen(.company(checkIn.product.subBrand.brand.brandOwner.id))
            )
            RouterLink(
                "brand.screen.open",
                systemImage: "cart",
                open: .screen(.brand(checkIn.product.subBrand.brand.id))
            )
            RouterLink(
                "subBrand.screen.open",
                systemImage: "cart",
                open: .screen(.subBrand(brandId: checkIn.product.subBrand.brand.id, subBrandId: checkIn.product.subBrand.id))
            )
            if let location = checkIn.location {
                RouterLink(
                    "location.open",
                    systemImage: "network",
                    open: .screen(.location(location.id))
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "location.open.purchaseLocation",
                    systemImage: "network",
                    open: .screen(.location(purchaseLocation.id))
                )
            }
            Divider()
            ReportButton(entity: .checkIn(checkIn))
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                if checkIn.profile.id == profileModel.id {
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
                    open: .screen(.company(checkIn.product.subBrand.brand.brandOwner.id))
                )
                RouterLink("product.screen.open", systemImage: "grid", open: .screen(.product(checkIn.product.id)))
                RouterLink(
                    "brand.screen.open", systemImage: "cart", open: .screen(.brand(checkIn.product.subBrand.brand.id))
                )
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    open: .screen(.subBrand(brandId: checkIn.product.subBrand.brand.id, subBrandId: checkIn.product.subBrand.id))
                )
                Divider()
                ReportButton(entity: .checkIn(checkIn))
                Divider()
                AdminRouterLink(open: .sheet(.checkInAdmin(id: id, onDelete: { _ in
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

    private func loadCheckInData(withHaptics: Bool = false) async {
        async let checkInPromise = repository.checkIn.getById(id: id)
        async let checkInCommentPromise = repository.checkInComment.getByCheckInId(id: id)
        async let markCheckInAsReadPromise: Void = notificationModel.markCheckInAsRead(
            id: id)
        do {
            let (checkInResult, checkInCommentResult, _) = try await (
                checkInPromise,
                checkInCommentPromise,
                markCheckInAsReadPromise
            )
            withAnimation {
                checkIn = checkInResult
                checkInComments = checkInCommentResult
                state = .populated
            }
        } catch {
            state = .getState(error: error, withHaptics: withHaptics, feedbackModel: feedbackModel)
            logger.error("Failed to load check-in screen. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteCheckIn(_: CheckIn.Joined) async {
        do {
            try await repository.checkIn.delete(id: id)
            feedbackModel.trigger(.notification(.success))
            router.removeLast()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete check-in. Error: \(error) (\(#file):\(#line))")
        }
    }
}
