import SwiftUI

struct HistoryView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "doc")
                    }
                }
            }
    }
}

#Preview {
    HistoryView()
}
