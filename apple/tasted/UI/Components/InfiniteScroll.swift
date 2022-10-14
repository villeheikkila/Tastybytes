import SwiftUI


struct InfiniteScroll<Data, Content>: View
where Data: RandomAccessCollection, Data.Element: Hashable, Data.Element: Identifiable, Content: View {
    @Binding var data: Data
    @Binding var isLoading: Bool
    let loadMore: () -> Void
    let content: (Data.Element) -> Content
    let refresh: (() -> Void)?

    init(data: Binding<Data>,
         isLoading: Binding<Bool>,
         loadMore: @escaping () -> Void,
         refresh: @escaping () -> Void,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        _data = data
        _isLoading = isLoading
        self.loadMore = loadMore
        self.content = content
        self.refresh = refresh
    }

    var body: some View {
        ScrollView() {
            LazyVStack {
                ForEach(data, id: \.id) { item in
                    content(item)
                        .onAppear {
                            if item == data.last && isLoading != true {
                                loadMore()
                            }
                        }
                }
                
            }
            
            if isLoading {
                ProgressView()
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            }
        }
        .refreshable {
            if let refresh = refresh {
                refresh()
            }
        }
        .task {
            loadMore()
        }
    }
}
