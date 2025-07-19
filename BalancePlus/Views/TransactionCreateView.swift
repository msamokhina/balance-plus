import SwiftUI

struct TransactionCreateView: View {
    @State var viewModel: CreateTransactionViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var commentIsFocused: Bool
    @FocusState private var amountIsFocused: Bool

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
                            AmountView(amount: $viewModel.amountField, isFocused: $amountIsFocused)
                            DateView(date: $viewModel.dateField)
                            TimeView(date: $viewModel.dateField)
                            CommentView(comment: $viewModel.commentField, isFocused: $commentIsFocused)
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
                    Button("Создать") {
                        viewModel.create()
                    }
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded { value in
                        if abs(value.translation.height) > abs(value.translation.width) && abs(value.translation.height) > 50 {
                            if commentIsFocused != false {
                                commentIsFocused = false
                            }
                            if amountIsFocused != false {
                                amountIsFocused = false
                            }
                        }
                    }
            )
            .alert("Ошибка", isPresented: $viewModel.showingAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "Ошибка")
            }
        }.tint(Color("NavigationColor"))
    }
}

#Preview {
    TransactionCreateView(viewModel: CreateTransactionViewModel(transactionsService: MockTransactionsService(), categoriesService: MockCategoriesService(), bankAccountService: MockBankAccountsService()))
}
