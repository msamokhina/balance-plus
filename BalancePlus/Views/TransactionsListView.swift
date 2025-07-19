import SwiftUI

struct TransactionsListView: View {
    @State var viewModel: TransactionsViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Загрузка транзакций...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else if viewModel.errorMessage != nil {
                        Button(
                            action: { viewModel.loadTransactions()},
                            label: { Text("Повторить загрузку") }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        List{
                            Section() {
                                SumView(sum: viewModel.sum)
                            }
                            
                            Section("Операции") {
                                if viewModel.transactions.count == 0 {
                                    Text("Операций за данный период нет")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    ForEach(viewModel.transactions) { transaction in
                                        TransactionRow(transaction: transaction)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                viewModel.editTransactionViewModel.show(
                                                    transactionId: transaction.id,
                                                    direction: viewModel.direction)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color("BackgroundColor"))
                .navigationTitle("\(viewModel.direction == .income ? "Доходы" : "Расходы") сегодня")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            HistoryView(viewModel: viewModel.historyViewModel)
                        } label: {
                            Image(systemName: "clock")
                        }
                    }
                }
                .task {
                    viewModel.loadTransactions()
                }
                .fullScreenCover(isPresented: $viewModel.editTransactionViewModel.showingDetailSheet) {
                    TransactionEditView(viewModel: viewModel.editTransactionViewModel)
                        .onDisappear {
                            viewModel.loadTransactions()
                        }
                }
                .fullScreenCover(isPresented: $viewModel.createTransactionViewModel.showingDetailSheet) {
                    TransactionCreateView(viewModel: viewModel.createTransactionViewModel)
                        .onDisappear {
                            viewModel.loadTransactions()
                        }
                }
                .alert("Ошибка", isPresented: $viewModel.showingAlert) {
                    Button("OK"){}
                } message: {
                    Text(viewModel.errorMessage ?? "Ошибка")
                }
                
                Button(action: {
                    viewModel.createTransactionViewModel.show(direction: viewModel.direction)
                }) {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .tint(Color("NavigationColor"))
    }
}

struct SumView: View {
    var sum: String
    
    var body: some View {
        HStack {
            Text("Всего")
            Spacer()
            Text(sum)
        }
    }
}

struct TransactionRow: View {
    var transaction: TransactionViewModel

    var body: some View {
        HStack {
            Text(String(transaction.categoryEmoji))
                .font(.system(size: 15))
                .frame(width: 26, height: 26)
                .background(Color("AccentColor").opacity(0.2))
                .cornerRadius(.infinity)

            VStack(alignment: .leading) {
                Text(transaction.categoryName)
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            
            Text(transaction.amountStr)
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let categoriesService = MockCategoriesService()
    let transactionsService = MockTransactionsService()
    let bankAccountService = MockBankAccountsService()
    
    TransactionsListView(viewModel: .init(
        direction: Direction.income,
        service: transactionsService,
        accountService: bankAccountService,
        editTransactionViewModel: .init(transactionsService: transactionsService, categoriesService: categoriesService),
        createTransactionViewModel: .init(transactionsService: transactionsService, categoriesService: categoriesService, bankAccountService: bankAccountService),
        
        historyViewModel: .init(
            state: .processing(HistoryViewModel.ProcessingViewModel(reason: .loading)),
            direction: Direction.income,
            selectedStartDate: Date().startOfDayMonthAgo(),
            selectedEndDate: Date().endOfDay(),
            transactionsService: transactionsService,
            accountService: bankAccountService,
            editTransactionViewModel: EditTransactionViewModel(
                transactionsService: transactionsService,
                categoriesService: categoriesService)
        )
    ))
}
