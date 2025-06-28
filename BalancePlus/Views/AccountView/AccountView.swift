import SwiftUI

enum AccountViewMode {
    case read
    case write
    case loading
}

struct AccountView: View {
    @State private var viewModel: AccountViewModel = AccountViewModel()
    @FocusState private var isBalanceInputFocused: Bool
    
    var body: some View {
        NavigationView {
            if viewModel.mode == .read || viewModel.mode == .loading {
                ScrollView {
                    BalanceView(mode: viewModel.mode, balance: $viewModel.balance, isFocused: $isBalanceInputFocused)
                    CurrencyView(mode: viewModel.mode, currency: $viewModel.currency)
                }
                .padding()
                .background(Color("BackgroundColor"))
                .navigationTitle("Мой счет")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.onEdit()
                        }) {
                            Text("Редактировать")
                        }.disabled(viewModel.mode == .loading)
                    }
                }
                .refreshable {
                    await viewModel.loadBalance()
                }
            } else {
                ScrollView {
                    BalanceView(mode: viewModel.mode, balance: $viewModel.balance, isFocused: $isBalanceInputFocused)
                    CurrencyView(mode: viewModel.mode, currency: $viewModel.currency)
                }
                .padding()
                .background(Color("BackgroundColor"))
                .navigationTitle("Мой счет")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.onSave()
                        }) {
                            Text("Сохранить")
                        }
                    }
                }
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
                .onTapGesture {
                    isBalanceInputFocused = false
                 }
            }
        }
        .task {
            await viewModel.loadBalance()
        }
        .background(Color("BackgroundColor"))
        .tint(Color("NavigationColor"))
    }
}


#Preview {
    AccountView()
}
