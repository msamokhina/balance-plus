import SwiftUI

struct HistoryView: View {
    @State var viewModel: HistoryViewModel

    var body: some View {
        VStack{
            List {
                Section {
                    DatePicker(
                        "Начало",
                        selection: $viewModel.selectedStartDate,
                        displayedComponents: .date
                    )
                    .tint(Color("AccentColor"))
                    .onChange(of: viewModel.selectedStartDate) {
                        viewModel.selectedStartDate = viewModel.selectedStartDate.startOfDay()
                        
                        if viewModel.selectedStartDate > viewModel.selectedEndDate {
                            viewModel.selectedEndDate = viewModel.selectedStartDate.endOfDay()
                        }
                        
                        viewModel.loadTransactions()
                    }
                    
                    DatePicker(
                        "Конец",
                        selection: $viewModel.selectedEndDate,
                        displayedComponents: .date
                    )
                    .tint(Color("AccentColor"))
                    .onChange(of: viewModel.selectedEndDate) {
                        viewModel.selectedEndDate = viewModel.selectedEndDate.endOfDay()
                        
                        if viewModel.selectedEndDate < viewModel.selectedStartDate {
                            viewModel.selectedStartDate = viewModel.selectedEndDate.startOfDay()
                        }
                        
                        viewModel.loadTransactions()
                    }
                    
                    HStack {
                        Text("Сортировка")
                        Spacer()
                        Menu(viewModel.sort == .byDate ? "По дате" : "По сумме") {
                            Button("По дате", action: {
                                viewModel.onSort(sortBy: .byDate)
                            })
                            Button("По сумме", action: {
                                viewModel.onSort(sortBy: .byAmount)
                            })
                        }
                    }
                    
                    HStack {
                        Text("Всего")
                        Spacer()
                        if case .processing(let processingViewModel) = viewModel.state {
                            Text(processingViewModel.reason.balanceText)
                        } else if case .idle(let idleViewModel) = viewModel.state {
                            Text(idleViewModel.totalAmount)
                        }
                    }
                }

                Section("Операции") {
                    switch viewModel.state {
                    case .processing(let processingViewModel):
                        ProgressView(processingViewModel.reason.transactionsText)
                            .frame(maxWidth: .infinity, alignment: .center)
                    case .error(_):
                        // TODO: научиться ретраить обновление если можно
                        Button(
                            action: { viewModel.loadTransactions()},
                            label: { Text("Повторить загрузку") }
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    case .idle(let idleViewModel):
                        if  idleViewModel.transactions.count == 0 {
                            Text("Операций за данный период нет")
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(idleViewModel.transactions) { transaction in
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
                        service: viewModel.transactionsService,
                        accountId: viewModel.account?.id ?? 1
                    )
                        .navigationTitle("Анализ")
                        .background(Color("BackgroundColor"))
                } label: {
                    Image(systemName: "doc")
                }
            }
        }
        .task {
            viewModel.loadTransactions()
        }
        .alert("Ошибка", isPresented: $viewModel.showingAlert) {
            Button("OK"){}
        } message: {
            if case .error(let errorViewModel) = viewModel.state {
                Text(errorViewModel.message)
            }
        }
        .fullScreenCover(isPresented: $viewModel.editTransactionViewModel.showingDetailSheet) {
            TransactionEditView(viewModel: viewModel.editTransactionViewModel)
                .onDisappear() {
                    viewModel.loadTransactions()
                }
        }
    }
}

#Preview {
    HistoryView(viewModel: HistoryViewModel(
        state: .processing(HistoryViewModel.ProcessingViewModel(reason: .loading)),
        direction: Direction.income,
        selectedStartDate: Date().startOfDayMonthAgo(),
        selectedEndDate: Date().endOfDay(),
        transactionsService: MockTransactionsService(),
        accountService: MockBankAccountsService(),
        editTransactionViewModel: EditTransactionViewModel(
            transactionsService: MockTransactionsService(),
            categoriesService: MockCategoriesService())
    ))
}
