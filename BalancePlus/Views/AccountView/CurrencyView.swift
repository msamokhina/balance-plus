import SwiftUI

struct CurrencyView: View {
    @State var mode: AccountViewMode
    @Binding var currency: String
    @State private var showingCurrencyDialog: Bool = false
    
    var body: some View {
        ZStack {
            if mode == .read {
                HStack {
                    Text("Валюта")
                    Spacer()
                    Text(currency)
                }
                .padding()
                .background(Color("AccentColor").opacity(0.2))
                .cornerRadius(10)
            } else if mode == .write {
                HStack {
                    Text("Валюта")
                    Spacer()
                    Text(currency)
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
                            self.currency = currency.symbol
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var currency: String = "$"
    VStack(spacing: 20) {
        CurrencyView(mode: .read, currency: $currency)
        CurrencyView(mode: .write, currency: $currency)
    }
}
