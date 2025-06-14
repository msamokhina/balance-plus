import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    
    var body: some View {
        if (direction == .income) {
            Text("Hello, Income!")
        } else {
            Text("Hello, Outcome!")
        }
    }
}

#Preview {
    TransactionsListView(direction: .income)
}
