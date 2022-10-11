import SwiftUI

struct SimpleCheckIn {
    let name: String
    let subBrandName: String
    let brandName: String
    let companyName: String
    let rating: Double
    let creator: String
}

struct ActivityView: View {
    var body: some View {
        ScrollView {
            ProductCard(simpleCheckIn: SimpleCheckIn(name: "Mango", subBrandName: "Zero", brandName: "Coca Cola", companyName: "Coca Cola Company", rating: 3.5, creator: "Ville Heikkilä"))
            ProductCard(simpleCheckIn: SimpleCheckIn(name: "Mango", subBrandName: "Zero", brandName: "Coca Cola", companyName: "Coca Cola Company", rating: 3.5, creator: "Ville Heikkilä"))
            ProductCard(simpleCheckIn: SimpleCheckIn(name: "Mango", subBrandName: "Zero", brandName: "Coca Cola", companyName: "Coca Cola Company", rating: 3.5, creator: "Ville Heikkilä"))
            ProductCard(simpleCheckIn: SimpleCheckIn(name: "Mango", subBrandName: "Zero", brandName: "Coca Cola", companyName: "Coca Cola Company", rating: 3.5, creator: "Ville Heikkilä"))
        }
    }
}

struct ProductCard: View {
    var simpleCheckIn: SimpleCheckIn

    var body: some View {
        HStack {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: "https://cdn-icons-png.flaticon.com/512/194/194938.png")) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)

                    Text(simpleCheckIn.creator)
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .cornerRadius(10).padding(.trailing, 10).padding(.leading, 10).padding(.top, 10)

                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Spacer()

                        Text(simpleCheckIn.brandName)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Text("\(simpleCheckIn.subBrandName) \(simpleCheckIn.name)")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Text(simpleCheckIn.companyName)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.gray)

                        Spacer()
                        HStack {
                            RatingView(rating: simpleCheckIn.rating)
                                .padding(.bottom, 10)
                        }
                    }
                    .padding(.all, 10)

                    Spacer()

                    Image(systemName: "wineglass")
                        .resizable()
                        .foregroundColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 80)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(.darkGray))
                .cornerRadius(5)
                .padding(.leading, 5)
                .padding(.trailing, 5)

                HStack {
                    Text("2022-01-01").font(.system(size: 12, weight: .medium, design: .default))
                    Spacer()
                    Button {} label: {
                        Text("5").font(.system(size: 14, weight: .bold, design: .default)).foregroundColor(.black)
                        Image(systemName: "hand.thumbsup.fill").frame(alignment: .leading).foregroundColor(Color(.systemYellow))
                    }
                }.padding(.trailing, 8).padding(.leading, 8).padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(10)
            }.background(Color(.tertiarySystemBackground)).cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)

        }.padding(.all, 10)
    }
}

struct RatingView: View {
    var rating: Double

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 5, id: \.self) { pos in
                if pos < Int(rating) {
                    Image(systemName: "star.fill").foregroundColor(Color(.yellow)).opacity(1.0)
                } else if Int(rating.rounded(.towardZero)) == pos && rating.truncatingRemainder(dividingBy: 1) == 0.5 {
                    Image(systemName: "star.leadinghalf.filled").foregroundColor(Color(.yellow)).opacity(1.0)
                } else {
                    Image(systemName: "star").foregroundColor(Color(.white)).opacity(0.4)
                }
            }
        }
    }
}
