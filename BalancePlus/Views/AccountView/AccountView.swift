import SwiftUI

struct AccountView: View {
    @State var viewModel: AccountViewModel
    @FocusState private var isBalanceInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .processing(let processingViewModel):
                    ProgressView(processingViewModel.reason.text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .error(_):
                    Button(
                        action: { viewModel.loadBankAccount()},
                        label: { Text("Повторить загрузку") }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .idle(let idleViewModel):
                    ScrollView {
                        IdleAccountView(viewModel: idleViewModel)
                    }
                    .padding()
                    .refreshable {
                        viewModel.onRefresh()
                    }

                case .editing(let editingViewModel):
                    ScrollView {
                        EditingAccountView(viewModel: editingViewModel, isFocused: $isBalanceInputFocused)
                    }
                    .padding()
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded { value in
                                if abs(value.translation.height) > abs(value.translation.width) && abs(value.translation.height) > 50 {
                                    if isBalanceInputFocused != false {
                                        isBalanceInputFocused = false
                                    }
                                }
                            }
                    )
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Мой счет")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if case .idle(_) = viewModel.state {
                        Button("Редактировать", action: {
                            viewModel.onEdit()
                        })
                    } else if case .editing(_) = viewModel.state {
                        Button("Сохранить", action: {
                            viewModel.onSave()
                        })
                    }
                }
            }
        }
        .tint(Color("NavigationColor"))
        .task {
            viewModel.loadBankAccount()
        }
        .alert("Ошибка", isPresented: $viewModel.showingAlert) {
            Button("OK"){}
        } message: {
            if case .error(let errorViewModel) = viewModel.state {
                Text(errorViewModel.message)
            }
        }
    }
}

struct IdleAccountView: View {
    @State var viewModel: AccountViewModel.IdleStateViewModel
    @State var spoilerIsOn = false
    
    var body: some View {
        HStack {
            Text("💰")
            Text("Баланс")
            Spacer()
            Text(viewModel.balance)
                .spoiler(isOn: $spoilerIsOn)
        }
        .padding()
        .background(Color("AccentColor"))
        .cornerRadius(10)
        
        HStack {
            Text("Валюта")
            Spacer()
            Text(viewModel.currency.symbol)
        }
        .padding()
        .background(Color("AccentColor").opacity(0.2))
        .cornerRadius(10)
    }
}

struct EditingAccountView: View {
    @State var viewModel: AccountViewModel.EditingStateViewModel
    @State private var showingCurrencyDialog: Bool = false
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack {
            Text("💰")
            Text("Баланс")
            Spacer()
            TextField("Введите баланс", text: $viewModel.balance)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .onChange(of: viewModel.balance) { oldValue, newValue in
                    let separator = Locale.current.decimalSeparator ?? ","
                    
                    var validSymbols: String = "0123456789"
                    validSymbols.append(separator)
                    
                    var filteredValue = newValue.filter { validSymbols.contains($0) }
                    
                    var components = filteredValue.components(separatedBy: separator)
                    if components.count > 2 {
                        components = [components[0], components[1]]
                    }
                    filteredValue = components.joined(separator: separator)
                    
                    if filteredValue != newValue {
                        viewModel.balance = filteredValue
                    }
                    // TODO: научиться ограничивать длину строки и 2 знака после запятой
                }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        
        HStack {
            Text("Валюта")
            Spacer()
            Text(viewModel.currency.symbol)
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .onTapGesture {
            self.showingCurrencyDialog = true
        }
        .confirmationDialog("Валюта", isPresented: $showingCurrencyDialog) {
            ForEach(Currency.allCases) { currency in
                Button("\(currency.fullName) (\(currency.symbol))") {
                    viewModel.currency = currency
                }
            }
        }
    }
}

#Preview {
    AccountView(viewModel: AccountViewModel(
        state: .processing(AccountViewModel.ProcessingViewModel(reason: .loading)),
        service: MockBankAccountsService()))
}
