import Models
import NukeUI
import OSLog
import Repositories
import SwiftUI

struct CheckInImagesView: View {
    private let logger = Logger(category: "CheckInImagesView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var checkInImages = [CheckIn.Image]()
    @State private var isLoading = false
    @State private var page = 0
    private let pageSize = 10

    let queryType: CheckInImageQueryType

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(checkInImages) { checkInImage in
                    CheckInImageCellView(checkInImage: checkInImage)
                        .onAppear {
                            if checkInImage == checkInImages.last, isLoading != true {
                                Task {
                                    await fetchImages()
                                }
                            }
                        }
                }
            }
        }
        .task {
            await fetchImages()
        }
    }

    func fetchImages() async {
        let (from, to) = getPagination(page: page, size: pageSize)
        isLoading = true

        switch await repository.checkIn.getCheckInImages(by: queryType, from: from, to: to) {
        case let .success(checkIns):
            await MainActor.run {
                withAnimation {
                    self.checkInImages.append(contentsOf: checkIns)
                }
                page += 1
                isLoading = false
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger
                .error(
                    "Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}

struct CheckInImageCellView: View {
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository

    let checkInImage: CheckIn.Image

    var body: some View {
        HStack {
            LazyImage(url: checkInImage.imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                } else {
                    BlurHashPlaceholder(blurHash: checkInImage.blurHash, height: 100)
                }
            }
            .frame(width: 100, height: 100)
            .onTapGesture {
                router.fetchAndNavigateTo(repository, .checkIn(id: checkInImage.id))
            }
        }
    }
}
