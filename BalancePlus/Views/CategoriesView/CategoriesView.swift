import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка категорий...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if viewModel.errorMessage != nil {
                    Button(
                        action: { viewModel.loadCategories()},
                        label: { Text("Повторить загрузку") }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List() {
                        Section("Статьи") {
                            ForEach(viewModel.filteredCategories) { category in
                                CategoryView(viewModel: category)
                            }
                        }
                    }.searchable(text: $viewModel.searchText)
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Мои статьи")
        }
        .tint(Color("NavigationColor"))
        .task {
            viewModel.loadCategories()
        }
        .alert("Ошибка", isPresented: $viewModel.showingAlert) {
            Button("OK"){}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    CategoriesView(
        viewModel: .init(service: MockCategoriesService())
    )
}
