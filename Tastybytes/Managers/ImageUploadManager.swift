import Observation
import OSLog
import SwiftUI

@Observable
class ImageUploadManager {
    var uploadedImageForCheckIn: CheckIn? = nil
    private let logger = Logger(category: "PermissionManager")

    private let repository: Repository
    private let feedbackManager: FeedbackManager

    init(repository: Repository, feedbackManager: FeedbackManager) {
        self.repository = repository
        self.feedbackManager = feedbackManager
    }

    func uploadCheckInImage(checkIn: CheckIn, image: UIImage) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.1) else { return }
            switch await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id) {
            case let .success(imageFile):
                await MainActor.run {
                    uploadedImageForCheckIn = checkIn.copyWith(imageFile: imageFile)
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                feedbackManager.toggle(.error(.unexpected))
                logger.error("Failed to upload image to check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
