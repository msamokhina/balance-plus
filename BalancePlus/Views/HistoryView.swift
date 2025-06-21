import SwiftUI

struct HistoryView: View {
    @State private var viewModel: TransactionsViewModel
    init(direction: Direction) {
        _viewModel = State(initialValue: TransactionsViewModel(direction: direction, selectedStartDate: Date().startOfDayMonthAgo(), selectedEndDate: Date().endOfDay()))
    }
    
    @State private var showingStartDatePickerPopover: Bool = false
    @State private var showingEndDatePickerPopover: Bool = false
    var body: some View {
        VStack{
            VStack {
                HStack {
                    Text("Моя история")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                
                
                VStack {
                    HStack {
                        Text("Начало")
                        Spacer()
                        DateLabel(date: $viewModel.selectedStartDate)
                            .onTapGesture {showingStartDatePickerPopover = true}
                            .popover(isPresented: $showingStartDatePickerPopover, attachmentAnchor: .point(.bottomLeading)) {
                                DatePicker(
                                    "Выберите дату",
                                    selection: $viewModel.selectedStartDate,
                                    displayedComponents: .date
                                )
                                .tint(Color("AccentColor"))
                                .datePickerStyle(.graphical)
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(width: 320, height: 350)
                                .presentationCompactAdaptation(.popover)
                                .onChange(of: viewModel.selectedStartDate) {
                                    viewModel.selectedStartDate = viewModel.selectedStartDate.startOfDay()
                                    
                                    if viewModel.selectedStartDate > viewModel.selectedEndDate {
                                        viewModel.selectedEndDate = viewModel.selectedStartDate.endOfDay()
                                    }
                                }
                            }
                    }
                    .padding(.bottom, 4)
                    
                    Divider().padding(.leading, 16)
                    HStack {
                        Text("Конец")
                        Spacer()
                        DateLabel(date: $viewModel.selectedEndDate)
                            .onTapGesture {showingEndDatePickerPopover = true}
                            .popover(isPresented: $showingEndDatePickerPopover, attachmentAnchor: .point(.bottomLeading)) {
                                DatePicker(
                                    "Выберите дату",
                                    selection: $viewModel.selectedEndDate,
                                    displayedComponents: .date
                                )
                                .tint(Color("AccentColor"))
                                .datePickerStyle(.graphical)
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(width: 320, height: 350)
                                .presentationCompactAdaptation(.popover)
                                .onChange(of: viewModel.selectedEndDate) {
                                    viewModel.selectedEndDate = viewModel.selectedEndDate.endOfDay()
                                    
                                    if viewModel.selectedEndDate < viewModel.selectedStartDate {
                                        viewModel.selectedStartDate = viewModel.selectedEndDate.startOfDay()
                                    }
                                }
                            }
                    }
                    .padding(.vertical, 4)
                    Divider().padding(.leading, 16)
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
                
                // TODO: убрать дублирование
                VStack{
                    HStack {
                        Spacer()
                        Menu(viewModel.sort == .byDate ? "По дате" : "По сумме") {
                            Button("По дате", action: {
                                viewModel.sortTransactions(sortBy: .byDate)
                            })
                            Button("По сумме", action: {
                                viewModel.sortTransactions(sortBy: .byAmount)
                            })
                        }
                        .padding()
                    }
                    
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
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
    // TODO: перенести во ViewModel
    // TODO: нужно выводить год если не текущий
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }
    
    @Binding
    var date: Date
    var body: some View {
        Text(date, formatter: dateFormatter)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color("AccentColor").opacity(0.2))
            .cornerRadius(8)
    }
}

#Preview {
    HistoryView(direction: .income)
}
