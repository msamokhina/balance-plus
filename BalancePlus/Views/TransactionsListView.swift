import SwiftUI

struct TransactionsListView: View {
    @State var viewModel: TransactionsViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                VStack {
                    VStack {
                        SumView(sum: viewModel.sum)
                        
                        HStack {
                            Text("ОПЕРАЦИИ")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        VStack{
                            if viewModel.isLoading {
                                ProgressView("Загрузка транзакций...")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            } else if  viewModel.transactions.count == 0 {
                                Text("Операций за данный период нет")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            } else if viewModel.transactions.count > 0 {
                                List(viewModel.transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.editTransactionViewModel.show(
                                                transactionId: transaction.id,
                                                direction: viewModel.direction)
                                        }
                                }
                                .listStyle(.plain)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                }
                .background(Color("BackgroundColor"))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            HistoryView(viewModel: TransactionsViewModel(direction: viewModel.direction, selectedStartDate: Date().startOfDayMonthAgo(), selectedEndDate: Date().endOfDay(), service: viewModel.service, editTransactionViewModel: viewModel.editTransactionViewModel, createTransactionViewModel: viewModel.createTransactionViewModel))
                        } label: {
                            Image(systemName: "clock")
                        }
                    }
                }
                .navigationTitle("\(viewModel.direction == .income ? "Доходы" : "Расходы") сегодня")
                .onAppear {
                    viewModel.loadTransactions()
                }
                .fullScreenCover(isPresented: $viewModel.editTransactionViewModel.showingDetailSheet) {
                    TransactionEditView(viewModel: viewModel.editTransactionViewModel)
                }
                .fullScreenCover(isPresented: $viewModel.createTransactionViewModel.showingDetailSheet) {
                    TransactionCreateView(viewModel: viewModel.createTransactionViewModel)
                }
            }
            .tint(Color("NavigationColor"))
            
            Button(action: {
                viewModel.createTransactionViewModel.show(direction: viewModel.direction)
            }) {
                Image(systemName: "plus")
                    .font(.title.weight(.semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
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
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct TransactionRow: View {
    var transaction: TransactionViewModel

    var body: some View {
        HStack {
            Text(String(transaction.categoryEmoji))
                .font(.system(size: 15))
                .frame(width: 25, height: 25)
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
    TransactionsListView(viewModel: .init(direction: Direction.income, service: MockTransactionsService(), editTransactionViewModel: .init(transactionsService: MockTransactionsService(), categoriesService: MockCategoriesService()), createTransactionViewModel: .init(transactionsService: MockTransactionsService(), categoriesService: MockCategoriesService())))
}
