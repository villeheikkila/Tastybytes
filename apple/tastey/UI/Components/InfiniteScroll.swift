import SwiftUI


struct InfiniteScrollView<Data, Content, Header>: View
where Data: RandomAccessCollection, Data.Element: Hashable, Data.Element: Identifiable, Content: View, Header: View {
    @Binding var data: Data
    @Binding var isLoading: Bool
    let loadMore: () -> Void
    let content: (Data.Element) -> Content
    let header: (() -> Header)
    let refresh: (() -> Void)?

    init(data: Binding<Data>,
         isLoading: Binding<Bool>,
         loadMore: @escaping () -> Void,
         refresh: @escaping () -> Void,
         @ViewBuilder content: @escaping (Data.Element) -> Content,
         @ViewBuilder header: @escaping () -> Header) {
        _data = data
        _isLoading = isLoading
        self.loadMore = loadMore
        self.header = header
        self.content = content
        self.refresh = refresh
    }

    var body: some View {
        ScrollView() {
            header()
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
