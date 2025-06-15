import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    
    var body: some View {
        VStack {
            HStack {
                Text("\(direction == .income ? "Доходы" : "Расходы") сегодня")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            HStack {
                Text("Всего")
                Spacer()
                Text("436 558 ₽")
            }
            .padding()
            .background()
            .cornerRadius(10)
            
            // TODO: добавить условие по наличию операций
            HStack {
                Text("ОПЕРАЦИИ")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            Spacer()
            List() {
            }
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    TransactionsListView(direction: .income)
        .background(Color("BackgroundColor"))
}
