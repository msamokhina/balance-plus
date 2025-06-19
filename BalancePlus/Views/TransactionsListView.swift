import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel: TransactionsViewModel
    init(direction: Direction) {
        _viewModel = State(initialValue: TransactionsViewModel(direction: direction))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Text("\(viewModel.direction == .income ? "Доходы" : "Расходы") сегодня")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                                    
                    SumView(viewModel: viewModel)
                    
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
                        }
                        else if viewModel.transactions.count > 0 {
                                List(viewModel.transactions) { transaction in
                                    NavigationLink {
                                        Text(transaction.amountStr)
                                    } label: {
                                        TransactionRow(transaction: transaction)
                                    }
                                }
                                .listStyle(.plain)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }.padding()

                Spacer()
            }
            .background(Color("BackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock")
                    }
                }
            }
            .onAppear {
                viewModel.loadTransactions()
            }
        }
        .tint(Color("NavigationColor"))
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
        }
    }
}

#Preview {
    TransactionsListView(direction:.income)
}
