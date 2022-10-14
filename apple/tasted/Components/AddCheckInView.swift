import SwiftUI

struct AddCheckInView: View {
    let product: ProductResponse
    @State var review: String = ""
    @State var rating: Int? = nil
    @Environment(\.dismiss) var dismiss
    let onCreation: ((_ checkIn: CheckInResponse) -> Void)


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
    
    struct NewCheckInRequest: Encodable {
        let rating: Int?
        let review: String
        let product_id: Int
        let created_by: String
        
    }
    
    func addCheckIn(productId: Int) {
        print("Add", productId)
        let addCheckInQuery = API.supabase.database
            .from("check_ins")
            .insert(values: NewCheckInRequest(rating: rating, review: review, product_id: productId, created_by: getCurrentUserId()), returning: .representation)
            .select(columns: "id, rating, review, created_at, profiles (id, username, avatar_url), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, avatar_url))")
            .limit(count: 1)
            .single()

        Task {
            let newCheckIn = try await addCheckInQuery.execute().decoded(to: CheckInResponse.self)
            onCreation(newCheckIn)
            dismiss()
        }
    }
}
