import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    
    var body: some View {
        BaseView(
            title: "Мои статьи",
            content: {
                List() {
                    Section("Статьи") {
                        ForEach(viewModel.filteredCategories) { category in
                            CategoryView(viewModel: category)
                        }
                    }
                }
            })
        .searchable(text: $viewModel.searchText)
        .task {
            viewModel.loadCategories()
        }
    }
}

#Preview {
    CategoriesView(
        viewModel: .init(service: MockCategoriesService())
    )
}
