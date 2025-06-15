import SwiftUI

struct OutcomeView: View {
    var body: some View {
        TransactionsListView(direction: .outcome)
            .background(Color("BackgroundColor"))
    }
}

#Preview {
    OutcomeView()
}
