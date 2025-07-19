import SwiftUI
import UIKit

struct AnalyseVCRepresentable: UIViewControllerRepresentable {
    let direction: Direction
    let selectedStartDate: Date
    let selectedEndDate: Date
    let service: TransactionsServiceProtocol
    let accountId: Int
    
    func makeUIViewController(context: Context) -> UIViewController {
        AnalyseViewController(
            selectedStartDate: selectedStartDate,
            selectedEndDate: selectedEndDate,
            direction: direction,
            service: service,
            accountId: accountId
        )
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct TableSection<Content> {
    let id: String
    let title: String?
    var data: [Content]
    
    init(id: String, title: String? = nil, data: [Content] = []) {
        self.id = id
        self.title = title
        self.data = data
    }
}

class AnalyseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DateCellDelegate, SortCellDelegate {
    private var sections: [TableSection<any TableCellContentRepresentable>] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let service: TransactionsServiceProtocol
    
    var selectedStartDate: Date
    var selectedEndDate: Date
    private let direction: Direction
    private var sortBy: TransactionsSortType = .byDate {
        didSet {
            updateSortCellUI()
        }
    }

    let accountId: Int
    private var isLoading: Bool = false {
        didSet {
            updateTransactionsSection()
        }
    }
    
    init(selectedStartDate: Date,
         selectedEndDate: Date,
         direction: Direction,
         service: TransactionsServiceProtocol,
         accountId: Int
    ) {
        self.selectedStartDate = selectedStartDate
        self.selectedEndDate = selectedEndDate
        self.direction = direction
        self.service = service
        self.accountId = accountId
        
        super.init(nibName: nil, bundle: nil)
        
        let initialConfigData: [any TableCellContentRepresentable] = [
            DateContent(title: "Период: начало", date: self.selectedStartDate, dateType: DateType.startDate),
            DateContent(title: "Период: конец", date: self.selectedEndDate, dateType: DateType.endDate),
            SortContent(title: "Сортировка", value: sortBy),
            TotalAmountContent(title: "Сумма", value: "Загрузка...")
        ]
        self.sections.append(TableSection(id: "Config", data: initialConfigData))
        self.sections.append(TableSection(id: "Transactions", title: "Операции", data: [LoadingContent()]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.register(TotalAmountCell.self, forCellReuseIdentifier: "TotalAmountCell")
        tableView.register(DateCell.self, forCellReuseIdentifier: "DateCell")
        tableView.register(SortCell.self, forCellReuseIdentifier: "SortCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "LoadingCell")
        tableView.register(ErrorCell.self, forCellReuseIdentifier: "ErrorCell")
        tableView.register(EmptyStateCell.self, forCellReuseIdentifier: "EmptyStateCell")
        
        Task {
            await fetchData()
        }
    }
    
    func sortTransactions(transactions: [Transaction]) -> [Transaction] {
        var sortedTransactions: [Transaction] = []
        if sortBy == .byDate {
            // По дате сортируем по убыванию, сверху всегда более свежие оперции
            sortedTransactions = transactions.sorted { $0.transactionDate < $1.transactionDate }
        } else {
            // По цене сортируем по возрастанию, предполагаю, что пользователю в первую очередь интересны крупные расходы
            sortedTransactions = transactions.sorted { $0.amount > $1.amount }
        }
        
        return sortedTransactions
    }
    
    func fetchData() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            var fetchedTransactions = try await service.fetchTransactions(
                accountId: accountId,
                from: selectedStartDate,
                to: selectedEndDate
            )
            fetchedTransactions = fetchedTransactions.filter { $0.category.direction == direction }
            let sortedTransactions = sortTransactions(transactions: fetchedTransactions)
            await MainActor.run {
                self.updateUI(with: sortedTransactions)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.showErrorState(message: "Не удалось загрузить данные. Проверьте подключение к интернету или попробуйте позже.")
            }
        }
    }
    
    func convert(data: [Transaction]) -> [TransactionContent] {
        let totalAmount = data.reduce(0) { sum, transaction in
            sum + transaction.amount
        }
        
        return data.map { transaction in
            TransactionContent(
                iconName: String(transaction.category.emoji),
                title: transaction.category.name,
                subtitle: transaction.comment,
                percentage: transaction.amount.percentageString(from: totalAmount),
                amount: "\(Int(truncating: NSDecimalNumber(decimal: transaction.amount)).formatted()) \(transaction.account.currency.symbol)"
            )
        }
    }
    
    func updateUI(with data: [Transaction]) {
        if let configIndex = sections.firstIndex(where: { $0.id == "Config" }) {
            var configSection = sections[configIndex]
            
            if let totalAmountContentIndex = configSection.data.firstIndex(where: { $0.reuseIdentifier == "TotalAmountCell" }) {
                
                let totalAmount = data.reduce(0) { sum, transaction in
                    sum + transaction.amount
                }
                let formattedAmount = "\(Int(truncating: NSDecimalNumber(decimal: totalAmount)).formatted()) ₽"
                let newTotalAmountContent = TotalAmountContent(title: "Сумма", value: formattedAmount)
                configSection.data[totalAmountContentIndex] = newTotalAmountContent
            }
            
            for (index, content) in configSection.data.enumerated() {
                if let dateContent = content as? DateContent {
                    switch dateContent.dateType {
                    case .startDate:
                        let newStartDateContent = DateContent(title: "Период: начало", date: self.selectedStartDate, dateType: DateType.startDate)
                        configSection.data[index] = newStartDateContent
                    case .endDate:
                        let newEndDateContent = DateContent(title: "Период: конец", date: self.selectedEndDate, dateType: DateType.endDate)
                        configSection.data[index] = newEndDateContent
                    }
                }
            }
            
            sections[configIndex] = configSection
            tableView.reloadSections(IndexSet(integer: configIndex), with: .automatic)
        }

        if let index = sections.firstIndex(where: { $0.id == "Transactions" }) {
            var sectionToUpdate = sections[index]
            if data.isEmpty {
                sectionToUpdate.data = [EmptyStateContent(message: "Операций за выбранный период не найдено.")]
            } else {
                sectionToUpdate.data = convert(data: data)
            }
            sections[index] = sectionToUpdate
            tableView.reloadSections(IndexSet(integer: index), with: .automatic)
        }
    }
    
    private func updateSortCellUI() {
        guard let configIndex = sections.firstIndex(where: { $0.id == "Config" }),
              let sortContentIndex = sections[configIndex].data.firstIndex(where: { $0.reuseIdentifier == "SortCell" }) else {
            return
        }
        
        var configSection = sections[configIndex]
        let newSortContent = SortContent(title: "Сортировка", value: self.sortBy)
        configSection.data[sortContentIndex] = newSortContent
        sections[configIndex] = configSection
        
        tableView.reloadRows(at: [IndexPath(row: sortContentIndex, section: configIndex)], with: .automatic)
    }
    
    private func updateTransactionsSection() {
        guard let transactionsIndex = sections.firstIndex(where: { $0.id == "Transactions" }) else { return }

        var transactionsSection = sections[transactionsIndex]

        if isLoading {
            transactionsSection.data = [LoadingContent()]
        } else {
            if transactionsSection.data.first?.reuseIdentifier == "LoadingCell" || transactionsSection.data.first?.reuseIdentifier == "ErrorCell" {
                transactionsSection.data = []
            }
        }
        sections[transactionsIndex] = transactionsSection
        tableView.reloadSections(IndexSet(integer: transactionsIndex), with: .automatic)
    }
    
    private func showErrorState(message: String) {
        guard let transactionsIndex = sections.firstIndex(where: { $0.id == "Transactions" }) else { return }
        
        var transactionsSection = sections[transactionsIndex]
        transactionsSection.data = [ErrorContent(message: message)]
        sections[transactionsIndex] = transactionsSection
        tableView.reloadSections(IndexSet(integer: transactionsIndex), with: .automatic)
        
        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = sections[indexPath.section].data
        let content = sectionData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: content.reuseIdentifier, for: indexPath)
        
        if let dateCell = cell as? DateCell {
            dateCell.delegate = self
        }
        if let sortCell = cell as? SortCell {
            sortCell.delegate = self
        }

        content.configure(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func dateCellChange(newDate: Date, for dateType: DateType) {
        switch dateType {
        case .startDate:
            self.selectedStartDate = newDate
            if (self.selectedStartDate > self.selectedEndDate) {
                self.selectedEndDate = self.selectedStartDate.endOfDay()
            }
        case .endDate:
            self.selectedEndDate = newDate
            if (self.selectedEndDate < self.selectedStartDate) {
                self.selectedStartDate = self.selectedEndDate.startOfDay()
            }
        }
        
        Task {
            await fetchData()
        }
    }
    
    func sortCell(_ cell: SortCell, didChangeSortType newType: TransactionsSortType) {
        self.sortBy = newType
        
        Task {
            await fetchData()
        }
    }
}

struct AnalyseViewController_Previews: PreviewProvider {
    static var previews: some View {
        AnalyseVCRepresentable(
            direction: Direction.income,
            selectedStartDate: Date().startOfDayMonthAgo(),
            selectedEndDate: Date().endOfDay(),
            service: MockTransactionsService(),
            accountId: 123
        )
            .background(Color("BackgroundColor"))
    }
}
