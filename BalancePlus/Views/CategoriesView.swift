import SwiftUI

struct CategoriesView: View {
    let viewModel: CategoriesViewModel
    
    var body: some View {
        BaseView(
            title: "Мои статьи",
            content: {
                List() {
                    Text("Hello, Categories!")
                }
            })
    }
}

#Preview {
    CategoriesView(
        viewModel: .init(service: MockCategoriesService())
    )
}
