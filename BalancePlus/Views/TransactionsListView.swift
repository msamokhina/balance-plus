import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel: TransactionsViewModel
    init(direction: Direction) {
        _viewModel = State(initialValue: TransactionsViewModel(direction: direction))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.direction == .income ? "Доходы" : "Расходы") сегодня")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            SumView(viewModel: viewModel)

            if viewModel.isLoading {
                ProgressView("Загрузка транзакций...")
            }
            else if viewModel.transactions.count > 0 {
                HStack {
                    Text("ОПЕРАЦИИ")
                        .font(.subheadline)
                        .foregroundColor(Color.secondary)
                    Spacer()
                }
                .padding(.top, 10)
                
                NavigationSplitView {
                    List(viewModel.transactions) { transaction in
                        NavigationLink {
                            Text(transaction.amountStr)
                        } label: {
                            TransactionRow(transaction: transaction)
                        }
                    }
                } detail: {
                    Text("Select a transaction")
                }
                .cornerRadius(10)
                .listStyle(.plain)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}

struct SumView: View {
    @Bindable var viewModel: TransactionsViewModel
    var body: some View {
        HStack {
            Text("Всего")
            Spacer()
            Text(viewModel.sum)
        }
        .padding()
        .background()
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
        }
    }
}

#Preview {
    TransactionsListView(direction:.income).background(Color("BackgroundColor"))
}
