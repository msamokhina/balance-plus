import SwiftUI

struct TransactionEditView: View {
    @State var viewModel: EditTransactionViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var commentIsFocused: Bool
    @FocusState private var amountIsFocused: Bool

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Подождите...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if viewModel.errorMessage != nil {
                    Text(viewModel.errorMessage ?? "Ошибка")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List() {
                        Section() {
                            CategorySelectView(currentCategory: $viewModel.categoryField, options: viewModel.categories)
                            AmountView(amount: $viewModel.amountField, isFocused: $amountIsFocused)
                            DateView(date: $viewModel.dateField)
                            TimeView(date: $viewModel.dateField)
                            CommentView(comment: $viewModel.commentField, isFocused: $commentIsFocused)
                        }
                        Section() {
                            DeleteTransactionView(action: viewModel.deleteTransaction)
                        }
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.save()
                    }
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded { value in
                        if abs(value.translation.height) > abs(value.translation.width) && abs(value.translation.height) > 50 {
                            if commentIsFocused != false {
                                commentIsFocused = false
                            }
                            if amountIsFocused != false {
                                amountIsFocused = false
                            }
                        }
                    }
            )
        }.tint(Color("NavigationColor"))
    }
}

struct CategorySelectView: View {
    @Binding var currentCategory: Category?
    var options: [Category]
    
    var body: some View {
        Picker("Статья", selection: $currentCategory) {
            Text("Выберите статью")
                .tag(nil as Category?)
            ForEach(options) { category in
                Text(category.name)
                    .tag(category)
            }
        }
    }
}

struct AmountView: View {
    @Binding var amount: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack {
            Text("Сумма")
            Spacer()
            TextField(
                "Введите сумму",
                text: $amount
            )
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .onChange(of: amount) { newValue in
                validateAndFormatInput(newValue)
            }
        }
    }
    
    private func validateAndFormatInput(_ newValue: String) {
        guard let decimalSeparator = Locale.current.decimalSeparator else {return}
        
        var cleanedValue = newValue
        var allowedCharacters = CharacterSet.decimalDigits
        allowedCharacters.insert(charactersIn: decimalSeparator)

        cleanedValue = String(cleanedValue.filter { character in
            character.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        })
        
        let components = cleanedValue.components(separatedBy: decimalSeparator)
        if components.count > 2 {
            cleanedValue = components.first! + decimalSeparator + components[1]
        }
        
        if amount != cleanedValue {
            amount = cleanedValue
        }
    }
}

struct DateView: View {
    @Binding var date: Date
    
    var body: some View {
        DatePicker(
            "Дата",
            selection: $date,
            in: ...Date(),
            displayedComponents: .date
        )
    }
}

struct TimeView: View {
    @Binding var date: Date
    
    var body: some View {
        DatePicker(
            "Время",
            selection: $date,
            displayedComponents: .hourAndMinute
        )
    }
}

struct DeleteTransactionView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text("Удалить расход")
        }
        .foregroundColor(.red)
    }
}

struct CommentView: View {
    @Binding var comment: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        TextField(
            "Комментарий",
            text: $comment
        )
        .focused($isFocused)
    }
    
    
}


#Preview {
    TransactionEditView(viewModel: EditTransactionViewModel(transactionsService: MockTransactionsService(), categoriesService: MockCategoriesService()))
}
