import EnvironmentModels
import Extensions
import Models
import Repositories
import SwiftUI

struct ProductsAdminScreen: View {
    @Environment(Repository.self) private var repository
    @State private var products = [Product.Joined]()
    @State private var state: ScreenState = .loading
    @State private var searchTerm = ""
    @State private var filteredProducts = [Product.Joined]()

    var body: some View {
        List(filteredProducts) { product in
            RouterLink(open: .sheet(.productAdmin(id: product.id, onUpdate: { product in
                products = products.replacingWithId(product.id, with: .init(product: product))
            }, onDelete: { id in
                products = products.removingWithId(id)
            }))) {
                ProductEntityView(product: product)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("productsAdmin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: searchTerm, task: {
            filteredProducts = await filter()
        })
        .initialTask {
            await initialize()
        }
    }

    private func initialize() async {
        do {
            products = try await repository.product.getAll()
            state = .populated
        } catch {
            state = .error([error])
        }
    }

    private func filter() async -> [Product.Joined] {
        await Task.detached(priority: .userInitiated) { [searchTerm] in
            guard !searchTerm.isEmpty else { return await products }
            return await products.filter { product in
                product.formatted(.fullName).localizedStandardContains(searchTerm)
            }
        }.value
    }
}
