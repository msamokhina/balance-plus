import SwiftUI
import Combine

struct BalanceView: View {
    @State var mode: AccountViewMode
    @Binding var balance: String
    @FocusState.Binding var isFocused: Bool
    @State var spoilerIsOn = false
    
    var body: some View {
        if mode == .read {
            HStack {
                Text("💰")
                Text("Баланс")
                Spacer()
                Text(balance)
                    .spoiler(isOn: $spoilerIsOn)
            }
            .padding()
            .background(Color("AccentColor"))
            .cornerRadius(10)
        } else if mode == .write {
            HStack {
                Text("💰")
                Text("Баланс")
                Spacer()
                TextField("Введите баланс", text: $balance)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .focused($isFocused)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(balance)) { newValue in
                        guard isFocused else { return }
                        
                        let validSymbols: String = "0123456789"
                        let isNegative = newValue.first == "-" ? "-" : ""

                        let filtered = isNegative + newValue.filter { validSymbols.contains($0) }
                            
                        if filtered != newValue {
                            self.balance = filtered
                        }
                    }
                    .onChange(of: isFocused) { oldValue, newValue in
                        if newValue {
                            let groupingSeparator: String = Locale.current.groupingSeparator ?? " "
                            balance = balance.replacingOccurrences(of: groupingSeparator, with: "")
                        } else {
                            balance = Int(balance)?.formatted() ?? "0"
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Spacer()
                        }
                        ToolbarItem(placement: .keyboard) {
                            Button {
                                isFocused = false
                            } label: {
                                Image(systemName: "keyboard.chevron.compact.down")
                            }
                        }
                    }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    @Previewable @State var balance: String = "1 000"
    @FocusState var isFocused: Bool
    BalanceView(mode: .read, balance: $balance, isFocused: $isFocused)
}
