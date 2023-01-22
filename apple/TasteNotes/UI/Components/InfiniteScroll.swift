import SwiftUI

struct InfiniteScrollView<Data, Content, Header>: View
  where Data: RandomAccessCollection, Data.Element: Hashable, Data.Element: Identifiable, Content: View, Header: View
{
  @State private var scrollProxy: ScrollViewProxy?
  @Binding var scrollToTop: Int
  @Binding var data: Data
  @Binding var isLoading: Bool
  private let topAnchor = "top"

  let initialLoad: () -> Void
  let loadMore: () -> Void
  let content: (Data.Element) -> Content
  let header: () -> Header
  let refresh: (() -> Void)?

  init(data: Binding<Data>,
       isLoading: Binding<Bool>,
       scrollToTop: Binding<Int>,
       initialLoad: (() -> Void)? = nil,
       loadMore: @escaping () -> Void,
       refresh: @escaping () -> Void,
       @ViewBuilder content: @escaping (Data.Element) -> Content,
       @ViewBuilder header: @escaping () -> Header)
  {
    _data = data
    _isLoading = isLoading
    _scrollToTop = scrollToTop
    self.initialLoad = initialLoad ?? loadMore
    self.loadMore = loadMore
    self.header = header
    self.content = content
    self.refresh = refresh
  }

  var body: some View {
    ScrollViewReader { proxy in
      ZStack(alignment: .top) {
        ScrollView {
          Rectangle()
            .frame(height: 0)
            .id(topAnchor)
          header()
          LazyVStack {
            ForEach(data, id: \.self) { item in
              content(item)
                .onAppear {
                  if item == data.last, isLoading != true {
                    loadMore()
                  }
                }
            }
          }.padding([.trailing, .leading], 5)

          if isLoading {
            ProgressView()
              .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
          }
        }
        .onAppear {
          scrollProxy = proxy
        }
        .onChange(of: scrollToTop, perform: { _ in
          withAnimation {
            scrollProxy?.scrollTo(topAnchor, anchor: .top)
          }
        })
        .refreshable {
          if let refresh {
            refresh()
          }
        }
        .task {
          initialLoad()
        }
      }
    }
  }
}
