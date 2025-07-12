import SwiftUI

struct TransactionEditView: View {
    @State var viewModel: EditTransactionViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var commentIsFocused: Bool

    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Подождите...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if viewModel.errorMessage != nil {
                    Text(viewModel.errorMessage ?? "Ошибка")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List() {
                        Section() {
                            CategorySelectView(currentCategory: $viewModel.categoryField, options: viewModel.categories)
                            Text("Сумма")
                            Text("Дата")
                            Text("Время")
                            CommentView(comment: $viewModel.commentField, isFocused: $commentIsFocused)
                        }
                        Section() {
                            DeleteTransactionView(action: viewModel.deleteTransaction)
                        }
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        dismiss()
                    }
                }
            }
        }.tint(Color("NavigationColor"))
    }
}

struct CommentView: View {
    @Binding var comment: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        TextField(
            "Комментарий",
            text: $comment
        )
        .focused($isFocused)
    }
}

struct CategorySelectView: View {
    @Binding var currentCategory: Category?
    var options: [Category]
    
    var body: some View {
        Picker("Статья", selection: $currentCategory) {
            ForEach(options) { category in
                Text(category.name)
                    .tag(category as Category?)
            }
        }
    }
}

struct DeleteTransactionView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text("Удалить расход")
        }
        .foregroundColor(.red)
    }
}

#Preview {
    TransactionEditView(viewModel: EditTransactionViewModel(transactionsService: MockTransactionsService(), categoriesService: MockCategoriesService()))
}
