import SwiftUI

struct AddCheckInView: View {
    let product: Product
    @State var review: String = ""
    @State var rating: Int? = nil
    @Environment(\.dismiss) var dismiss
    let onCreation: (_ checkIn: CheckIn) -> Void

    var body: some View {
        VStack {
            ProductCardView(product: product)
            Form {
                Section {
                    TextField("How was it?", text: $review)
                    RatingPicker(rating: $rating)
                } header: {
                    Text("Review")
                }.headerProminence(.increased)

                Button("Check-in!", action: {
                    addCheckIn(productId: product.id)
                })
            }
        }
    }

    func addCheckIn(productId: Int) {
        let newCheckIn = NewCheckIn(productId: productId, createdBy: SupabaseAuthRepository().getCurrentUserId(), rating: rating, review: review)

        Task {
            let newCheckIn = try await SupabaseCheckInRepository().insert(newCheckIn: newCheckIn)
            onCreation(newCheckIn)
            dismiss()
        }
    }
}
