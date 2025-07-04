import SwiftUI

struct CategoryView: View {
    let viewModel: CategoryViewModel
    var body: some View {
        HStack {
            Text(String(viewModel.emoji))
                .font(.system(size: 15))
                .frame(width: 26, height: 26)
                .background(Color("AccentColor").opacity(0.2))
                .cornerRadius(.infinity)
            Text(viewModel.name)
        }
    }
}

#Preview {
    CategoryView(viewModel: CategoryViewModel(id: 0, emoji: "💰", name: "Зарплата"))
}
