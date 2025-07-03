import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    
    var body: some View {
        BaseView(
            title: "Мои статьи",
            content: {
                List() {
                    Section("Статьи") {
                        ForEach(viewModel.categories) { category in
                            Text(category.name)
                        }
                    }
                }
            }).task {
                viewModel.loadCategories()
            }
    }
}

#Preview {
    CategoriesView(
        viewModel: .init(service: MockCategoriesService())
    )
}
