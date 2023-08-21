import Models
import Observation
import OSLog
import Repositories
import SwiftUI

@Observable
public class ImageUploadEnvironmentModel {
    public var uploadedImageForCheckIn: CheckIn? = nil
    private let logger = Logger(category: "PermissionEnvironmentModel")

    private let repository: Repository
    private let feedbackEnvironmentModel: FeedbackEnvironmentModel

    public init(repository: Repository, feedbackEnvironmentModel: FeedbackEnvironmentModel) {
        self.repository = repository
        self.feedbackEnvironmentModel = feedbackEnvironmentModel
    }

    public func uploadCheckInImage(checkIn: CheckIn, image: UIImage) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.1) else { return }
            switch await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id) {
            case let .success(imageFile):
                await MainActor.run {
                    uploadedImageForCheckIn = checkIn.copyWith(imageFile: imageFile)
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                feedbackEnvironmentModel.toggle(.error(.unexpected))
                logger.error("Failed to upload image to check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
