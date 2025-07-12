import SwiftUI

struct HistoryView: View {
    @State var viewModel: TransactionsViewModel

    var body: some View {
        VStack{
            VStack {
                VStack {
                    HStack {
                        Text("Начало")
                        Spacer()
                        DateLabel(date: viewModel.selectedStartDate)
                            .overlay {
                                DatePicker(
                                    selection: $viewModel.selectedStartDate,
                                    displayedComponents: .date
                                ){}.colorMultiply(.clear)
                                    .tint(Color("AccentColor"))
                                    .onChange(of: viewModel.selectedStartDate) {
                                        viewModel.selectedStartDate = viewModel.selectedStartDate.startOfDay()
                                        
                                        if viewModel.selectedStartDate > viewModel.selectedEndDate {
                                            viewModel.selectedEndDate = viewModel.selectedStartDate.endOfDay()
                                        }
                                    }
                            }
                    }
                    
                    Divider().padding(.leading, 8)
                    HStack {
                        Text("Конец")
                        Spacer()
                        DateLabel(date: viewModel.selectedEndDate)
                            .overlay {
                                DatePicker(
                                    selection: $viewModel.selectedEndDate,
                                    displayedComponents: .date
                                ){}.colorMultiply(.clear)
                                    .tint(Color("AccentColor"))
                                    .onChange(of: viewModel.selectedEndDate) {
                                        viewModel.selectedEndDate = viewModel.selectedEndDate.endOfDay()
                                        
                                        if viewModel.selectedEndDate < viewModel.selectedStartDate {
                                            viewModel.selectedStartDate = viewModel.selectedEndDate.startOfDay()
                                        }
                                    }
                            }
                    }
                    
                    Divider().padding(.leading, 8)
                    HStack {
                        Text("Сортировка")
                        Spacer()
                        Menu(viewModel.sort == .byDate ? "По дате" : "По сумме") {
                            Button("По дате", action: {
                                viewModel.sortTransactions(sortBy: .byDate)
                            })
                            Button("По сумме", action: {
                                viewModel.sortTransactions(sortBy: .byAmount)
                            })
                        }
                    }
                    .padding(.top, 4)
                    
                    Divider().padding(.leading, 8)
                    HStack {
                        Text("Всего")
                        Spacer()
                        Text(viewModel.sum)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
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
            }
            .padding()
            .background(Color("BackgroundColor"))
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AnalyseVCRepresentable(
                        direction: viewModel.direction,
                        selectedStartDate: viewModel.selectedStartDate,
                        selectedEndDate: viewModel.selectedEndDate,
                        service: viewModel.service
                    )
                        .navigationTitle("Анализ")
                        .background(Color("BackgroundColor"))
                } label: {
                    Image(systemName: "doc")
                }
            }
        }
        // TODO: подумать про гонки
        .onChange(of: viewModel.selectedStartDate) {
            viewModel.loadTransactions()
        }
        .onChange(of: viewModel.selectedEndDate) {
            viewModel.loadTransactions()
        }
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}

struct DateLabel: View {
    var date: Date
    var body: some View {
        Text(date.formattedDayMonthYear())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color("AccentColor").opacity(0.2))
            .cornerRadius(8)
    }
}

#Preview {
    HistoryView(viewModel: .init(
        direction: Direction.income,
        service: MockTransactionsService(),
        editTransactionViewModel: .init(transactionsService: MockTransactionsService(), categoriesService: MockCategoriesService())))
}
