import SwiftUI

struct CurrencyView: View {
    @State var mode: AccountViewMode
    @Binding var currency: String
    @State private var showingCurrencySheet: Bool = false
    
    @EnvironmentObject var popupManager: PopupManager
    
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
                    popupManager.showPopup(content: DetailView(currency: $currency))
                }
            }
        }
    }
}

struct DetailView: View {
    @EnvironmentObject var popupManager: PopupManager
    @Binding var currency: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
                .onTapGesture() {
                    popupManager.hidePopup()
                }
            VStack {
                Spacer()
                VStack {
                    Text("Валюта")
                        .bold()
                        .padding(8)
                    Divider()
                    
                    ForEach(Currency.allCases) { currency in
                        Button("\(currency.fullName) (\(currency.symbol))") {
                            popupManager.hidePopup()
                            self.currency = currency.symbol
                        }
                        .foregroundColor(Color("NavigationColor"))
                        .padding(8)
                        Divider()
                    }
                }
                .background(Color("BackgroundColor"))
                .cornerRadius(10)
                .padding()
            }
        }
    }
}

#Preview {
    @Previewable @State var currency: String = "$"
    VStack(spacing: 20) {
        CurrencyView(mode: .read, currency: $currency)
        CurrencyView(mode: .write, currency: $currency).environmentObject(PopupManager())
    }
}
