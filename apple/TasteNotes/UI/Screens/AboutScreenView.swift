import SwiftUI

struct AboutScreenView: View {
  @StateObject private var viewModel = ViewModel()

  var body: some View {
    VStack {
      if let aboutPage = viewModel.aboutPage {
        List {
          Section {
            HStack {
              Spacer()
              VStack(spacing: 10) {
                AppLogoView()
                AppNameView()
              }
              Spacer()
            }
          }
          .listRowBackground(Color.clear)

          Section {
            Text(aboutPage.summary)
          }

          Section {
            Link(destination: URL(string: aboutPage.githubUrl)!) {
              HStack {
                GitHubShape()
                  .frame(width: 18, height: 18)
                  .padding(.leading, 5)
                  .padding(.trailing, 15)

                Text("GitHub")
                  .fontWeight(.medium)
              }
            }
            Link(destination: URL(string: aboutPage.portfolioUrl)!) {
              HStack {
                WebShape()
                  .frame(width: 18, height: 18)
                  .padding(.leading, 5)
                  .padding(.trailing, 15)

                Text("Portfolio")
                  .fontWeight(.medium)
              }
            }
            Link(destination: URL(string: aboutPage.linkedInUrl)!) {
              HStack {
                LinkedInShape()
                  .frame(width: 18, height: 18)
                  .padding(.leading, 5)
                  .padding(.trailing, 15)

                Text("LinkedIn")
                  .fontWeight(.medium)
              }
            }
          }

          Section {
            HStack(alignment: .center) {
              Image(systemName: "c.circle")
                .font(.system(size: 12, weight: .bold, design: .default))

              if let currentYear = viewModel.currentYear {
                Text(String(currentYear))
                  .font(.system(size: 12, weight: .bold, design: .default))
              }
              Text("Ville Heikkilä")
                .font(.system(size: 12, weight: .bold, design: .default))
            }
          }
        }
      }
    }
    .navigationTitle("About")
    .task {
      viewModel.getAboutPage()
    }
  }
}

extension AboutScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var aboutPage: AboutPage?
    let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year

    func getAboutPage() {
      Task {
        switch await repository.document.getAboutPage() {
        case let .success(aboutPage):
          self.aboutPage = aboutPage
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}

struct AboutScreenView_Previews: PreviewProvider {
  static var previews: some View {
    AboutScreenView()
  }
}

struct GitHubShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.5 * width, y: 0))
    path.addCurve(
      to: CGPoint(x: 0, y: 0.5 * height),
      control1: CGPoint(x: 0.22392 * width, y: 0),
      control2: CGPoint(x: 0, y: 0.22388 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.34196 * width, y: 0.97446 * height),
      control1: CGPoint(x: 0, y: 0.72092 * height),
      control2: CGPoint(x: 0.14325 * width, y: 0.90833 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.375 * width, y: 0.95042 * height),
      control1: CGPoint(x: 0.36692 * width, y: 0.97908 * height),
      control2: CGPoint(x: 0.375 * width, y: 0.96358 * height)
    )
    path.addLine(to: CGPoint(x: 0.375 * width, y: 0.85733 * height))
    path.addCurve(
      to: CGPoint(x: 0.20696 * width, y: 0.79833 * height),
      control1: CGPoint(x: 0.23592 * width, y: 0.88758 * height),
      control2: CGPoint(x: 0.20696 * width, y: 0.79833 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.15142 * width, y: 0.72517 * height),
      control1: CGPoint(x: 0.18421 * width, y: 0.74054 * height),
      control2: CGPoint(x: 0.15142 * width, y: 0.72517 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.15487 * width, y: 0.69479 * height),
      control1: CGPoint(x: 0.10604 * width, y: 0.69412 * height),
      control2: CGPoint(x: 0.15487 * width, y: 0.69479 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.2315 * width, y: 0.74633 * height),
      control1: CGPoint(x: 0.20508 * width, y: 0.69829 * height),
      control2: CGPoint(x: 0.2315 * width, y: 0.74633 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.377 * width, y: 0.78787 * height),
      control1: CGPoint(x: 0.27608 * width, y: 0.82275 * height),
      control2: CGPoint(x: 0.34846 * width, y: 0.80067 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.40875 * width, y: 0.72104 * height),
      control1: CGPoint(x: 0.38146 * width, y: 0.75558 * height),
      control2: CGPoint(x: 0.39442 * width, y: 0.7335 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.18096 * width, y: 0.47392 * height),
      control1: CGPoint(x: 0.29771 * width, y: 0.70833 * height),
      control2: CGPoint(x: 0.18096 * width, y: 0.66546 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.23246 * width, y: 0.33971 * height),
      control1: CGPoint(x: 0.18096 * width, y: 0.41929 * height),
      control2: CGPoint(x: 0.2005 * width, y: 0.37471 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.23733 * width, y: 0.20737 * height),
      control1: CGPoint(x: 0.22729 * width, y: 0.32708 * height),
      control2: CGPoint(x: 0.21017 * width, y: 0.27621 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.37488 * width, y: 0.25862 * height),
      control1: CGPoint(x: 0.23733 * width, y: 0.20737 * height),
      control2: CGPoint(x: 0.27933 * width, y: 0.19396 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: 0.24179 * height),
      control1: CGPoint(x: 0.41475 * width, y: 0.24754 * height),
      control2: CGPoint(x: 0.4575 * width, y: 0.242 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.62525 * width, y: 0.25862 * height),
      control1: CGPoint(x: 0.5425 * width, y: 0.242 * height),
      control2: CGPoint(x: 0.58529 * width, y: 0.24754 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.76262 * width, y: 0.20737 * height),
      control1: CGPoint(x: 0.72071 * width, y: 0.19396 * height),
      control2: CGPoint(x: 0.76262 * width, y: 0.20737 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.76754 * width, y: 0.33971 * height),
      control1: CGPoint(x: 0.78983 * width, y: 0.27625 * height),
      control2: CGPoint(x: 0.77271 * width, y: 0.32712 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.819 * width, y: 0.47392 * height),
      control1: CGPoint(x: 0.79962 * width, y: 0.37471 * height),
      control2: CGPoint(x: 0.819 * width, y: 0.41933 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.59071 * width, y: 0.72062 * height),
      control1: CGPoint(x: 0.819 * width, y: 0.66596 * height),
      control2: CGPoint(x: 0.70204 * width, y: 0.70825 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.625 * width, y: 0.81321 * height),
      control1: CGPoint(x: 0.60862 * width, y: 0.73612 * height),
      control2: CGPoint(x: 0.625 * width, y: 0.76654 * height)
    )
    path.addLine(to: CGPoint(x: 0.625 * width, y: 0.95042 * height))
    path.addCurve(
      to: CGPoint(x: 0.65838 * width, y: 0.97442 * height),
      control1: CGPoint(x: 0.625 * width, y: 0.96371 * height),
      control2: CGPoint(x: 0.633 * width, y: 0.97933 * height)
    )
    path.addCurve(
      to: CGPoint(x: width, y: 0.5 * height),
      control1: CGPoint(x: 0.85692 * width, y: 0.90821 * height),
      control2: CGPoint(x: width, y: 0.72083 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: 0),
      control1: CGPoint(x: width, y: 0.22388 * height),
      control2: CGPoint(x: 0.77612 * width, y: 0)
    )
    path.closeSubpath()
    return path
  }
}

struct LinkedInShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.79167 * width, y: 0))
    path.addLine(to: CGPoint(x: 0.20833 * width, y: 0))
    path.addCurve(
      to: CGPoint(x: 0, y: 0.20833 * height),
      control1: CGPoint(x: 0.09329 * width, y: 0),
      control2: CGPoint(x: 0, y: 0.09329 * height)
    )
    path.addLine(to: CGPoint(x: 0, y: 0.79167 * height))
    path.addCurve(
      to: CGPoint(x: 0.20833 * width, y: height),
      control1: CGPoint(x: 0, y: 0.90671 * height),
      control2: CGPoint(x: 0.09329 * width, y: height)
    )
    path.addLine(to: CGPoint(x: 0.79167 * width, y: height))
    path.addCurve(
      to: CGPoint(x: width, y: 0.79167 * height),
      control1: CGPoint(x: 0.90675 * width, y: height),
      control2: CGPoint(x: width, y: 0.90671 * height)
    )
    path.addLine(to: CGPoint(x: width, y: 0.20833 * height))
    path.addCurve(
      to: CGPoint(x: 0.79167 * width, y: 0),
      control1: CGPoint(x: width, y: 0.09329 * height),
      control2: CGPoint(x: 0.90675 * width, y: 0)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.33333 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.20833 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.20833 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.33333 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.33333 * width, y: 0.79167 * height))
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.27083 * width, y: 0.2805 * height))
    path.addCurve(
      to: CGPoint(x: 0.19792 * width, y: 0.207 * height),
      control1: CGPoint(x: 0.23058 * width, y: 0.2805 * height),
      control2: CGPoint(x: 0.19792 * width, y: 0.24758 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.27083 * width, y: 0.1335 * height),
      control1: CGPoint(x: 0.19792 * width, y: 0.16642 * height),
      control2: CGPoint(x: 0.23058 * width, y: 0.1335 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.34375 * width, y: 0.207 * height),
      control1: CGPoint(x: 0.31108 * width, y: 0.1335 * height),
      control2: CGPoint(x: 0.34375 * width, y: 0.16642 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.27083 * width, y: 0.2805 * height),
      control1: CGPoint(x: 0.34375 * width, y: 0.24758 * height),
      control2: CGPoint(x: 0.31112 * width, y: 0.2805 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.83333 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.70833 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.70833 * width, y: 0.55817 * height))
    path.addCurve(
      to: CGPoint(x: 0.54167 * width, y: 0.55817 * height),
      control1: CGPoint(x: 0.70833 * width, y: 0.41783 * height),
      control2: CGPoint(x: 0.54167 * width, y: 0.42846 * height)
    )
    path.addLine(to: CGPoint(x: 0.54167 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.41667 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.41667 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.54167 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.54167 * width, y: 0.40688 * height))
    path.addCurve(
      to: CGPoint(x: 0.83333 * width, y: 0.51004 * height),
      control1: CGPoint(x: 0.59983 * width, y: 0.29913 * height),
      control2: CGPoint(x: 0.83333 * width, y: 0.29117 * height)
    )
    path.addLine(to: CGPoint(x: 0.83333 * width, y: 0.79167 * height))
    path.closeSubpath()
    return path
  }
}

struct WebShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.5 * width, y: 0))
    path.addCurve(
      to: CGPoint(x: width, y: 0.5 * height),
      control1: CGPoint(x: 0.77596 * width, y: 0),
      control2: CGPoint(x: width, y: 0.22404 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: height),
      control1: CGPoint(x: width, y: 0.77596 * height),
      control2: CGPoint(x: 0.77596 * width, y: height)
    )
    path.addCurve(
      to: CGPoint(x: 0, y: 0.5 * height),
      control1: CGPoint(x: 0.22404 * width, y: height),
      control2: CGPoint(x: 0, y: 0.77596 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: 0),
      control1: CGPoint(x: 0, y: 0.22404 * height),
      control2: CGPoint(x: 0.22404 * width, y: 0)
    )
    path.move(to: CGPoint(x: 0.60654 * width, y: 0.66667 * height))
    path.addLine(to: CGPoint(x: 0.39342 * width, y: 0.66667 * height))
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: 0.906 * height),
      control1: CGPoint(x: 0.41617 * width, y: 0.76917 * height),
      control2: CGPoint(x: 0.45346 * width, y: 0.83808 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.60654 * width, y: 0.66667 * height),
      control1: CGPoint(x: 0.54975 * width, y: 0.83346 * height),
      control2: CGPoint(x: 0.58504 * width, y: 0.76392 * height)
    )
    path.move(to: CGPoint(x: 0.30833 * width, y: 0.66667 * height))
    path.addLine(to: CGPoint(x: 0.11804 * width, y: 0.66667 * height))
    path.addCurve(
      to: CGPoint(x: 0.3995 * width, y: 0.90483 * height),
      control1: CGPoint(x: 0.16954 * width, y: 0.78437 * height),
      control2: CGPoint(x: 0.27238 * width, y: 0.87383 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.30833 * width, y: 0.66667 * height),
      control1: CGPoint(x: 0.35583 * width, y: 0.83263 * height),
      control2: CGPoint(x: 0.32521 * width, y: 0.75242 * height)
    )
    path.move(to: CGPoint(x: 0.88196 * width, y: 0.66667 * height))
    path.addLine(to: CGPoint(x: 0.69167 * width, y: 0.66667 * height))
    path.addCurve(
      to: CGPoint(x: 0.60104 * width, y: 0.90392 * height),
      control1: CGPoint(x: 0.67538 * width, y: 0.7495 * height),
      control2: CGPoint(x: 0.64604 * width, y: 0.82863 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.88196 * width, y: 0.66667 * height),
      control1: CGPoint(x: 0.72654 * width, y: 0.87212 * height),
      control2: CGPoint(x: 0.83092 * width, y: 0.78329 * height)
    )
    path.move(to: CGPoint(x: 0.29842 * width, y: 0.41667 * height))
    path.addLine(to: CGPoint(x: 0.09167 * width, y: 0.41667 * height))
    path.addCurve(
      to: CGPoint(x: 0.09167 * width, y: 0.58333 * height),
      control1: CGPoint(x: 0.08054 * width, y: 0.47138 * height),
      control2: CGPoint(x: 0.08054 * width, y: 0.52854 * height)
    )
    path.addLine(to: CGPoint(x: 0.29646 * width, y: 0.58333 * height))
    path.addCurve(
      to: CGPoint(x: 0.29842 * width, y: 0.41667 * height),
      control1: CGPoint(x: 0.2915 * width, y: 0.52796 * height),
      control2: CGPoint(x: 0.29225 * width, y: 0.472 * height)
    )
    path.move(to: CGPoint(x: 0.61762 * width, y: 0.41667 * height))
    path.addLine(to: CGPoint(x: 0.38233 * width, y: 0.41667 * height))
    path.addCurve(
      to: CGPoint(x: 0.38012 * width, y: 0.58333 * height),
      control1: CGPoint(x: 0.37546 * width, y: 0.47192 * height),
      control2: CGPoint(x: 0.37462 * width, y: 0.528 * height)
    )
    path.addLine(to: CGPoint(x: 0.61983 * width, y: 0.58333 * height))
    path.addCurve(
      to: CGPoint(x: 0.61762 * width, y: 0.41667 * height),
      control1: CGPoint(x: 0.62538 * width, y: 0.528 * height),
      control2: CGPoint(x: 0.62446 * width, y: 0.47196 * height)
    )
    path.move(to: CGPoint(x: 0.90833 * width, y: 0.41667 * height))
    path.addLine(to: CGPoint(x: 0.70154 * width, y: 0.41667 * height))
    path.addCurve(
      to: CGPoint(x: 0.70354 * width, y: 0.58333 * height),
      control1: CGPoint(x: 0.70771 * width, y: 0.472 * height),
      control2: CGPoint(x: 0.70846 * width, y: 0.52796 * height)
    )
    path.addLine(to: CGPoint(x: 0.90833 * width, y: 0.58333 * height))
    path.addCurve(
      to: CGPoint(x: 0.90833 * width, y: 0.41667 * height),
      control1: CGPoint(x: 0.91917 * width, y: 0.52979 * height),
      control2: CGPoint(x: 0.91971 * width, y: 0.473 * height)
    )
    path.move(to: CGPoint(x: 0.40183 * width, y: 0.09463 * height))
    path.addCurve(
      to: CGPoint(x: 0.11804 * width, y: 0.33333 * height),
      control1: CGPoint(x: 0.27362 * width, y: 0.12513 * height),
      control2: CGPoint(x: 0.16987 * width, y: 0.21488 * height)
    )
    path.addLine(to: CGPoint(x: 0.31192 * width, y: 0.33333 * height))
    path.addCurve(
      to: CGPoint(x: 0.40183 * width, y: 0.09463 * height),
      control1: CGPoint(x: 0.33004 * width, y: 0.24825 * height),
      control2: CGPoint(x: 0.361 * width, y: 0.16729 * height)
    )
    path.move(to: CGPoint(x: 0.49996 * width, y: 0.09262 * height))
    path.addCurve(
      to: CGPoint(x: 0.39733 * width, y: 0.33333 * height),
      control1: CGPoint(x: 0.45458 * width, y: 0.16637 * height),
      control2: CGPoint(x: 0.42037 * width, y: 0.2365 * height)
    )
    path.addLine(to: CGPoint(x: 0.60262 * width, y: 0.33333 * height))
    path.addCurve(
      to: CGPoint(x: 0.49996 * width, y: 0.09262 * height),
      control1: CGPoint(x: 0.58037 * width, y: 0.23975 * height),
      control2: CGPoint(x: 0.54692 * width, y: 0.16883 * height)
    )
    path.move(to: CGPoint(x: 0.59862 * width, y: 0.0955 * height))
    path.addCurve(
      to: CGPoint(x: 0.68804 * width, y: 0.33333 * height),
      control1: CGPoint(x: 0.64083 * width, y: 0.171 * height),
      control2: CGPoint(x: 0.67083 * width, y: 0.25217 * height)
    )
    path.addLine(to: CGPoint(x: 0.88196 * width, y: 0.33333 * height))
    path.addCurve(
      to: CGPoint(x: 0.59862 * width, y: 0.0955 * height),
      control1: CGPoint(x: 0.83062 * width, y: 0.216 * height),
      control2: CGPoint(x: 0.72521 * width, y: 0.12675 * height)
    )
    return path
  }
}
