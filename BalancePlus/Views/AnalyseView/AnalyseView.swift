import SwiftUI
import UIKit

struct AnalyseVCRepresentable: UIViewControllerRepresentable {
    let direction: Direction
    let selectedStartDate: Date
    let selectedEndDate: Date
    let service: TransactionsServiceProtocol
    
    func makeUIViewController(context: Context) -> UIViewController {
        AnalyseViewController(
            selectedStartDate: selectedStartDate,
            selectedEndDate: selectedEndDate,
            direction: direction,
            service: service
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
    private var sortBy: TransactionsSortType = .byDate

    init(selectedStartDate: Date,
         selectedEndDate: Date,
         direction: Direction,
         service: TransactionsServiceProtocol
    ) {
        self.selectedStartDate = selectedStartDate
        self.selectedEndDate = selectedEndDate
        self.direction = direction
        self.service = service
        
        super.init(nibName: nil, bundle: nil)
        
        let initialConfigData: [any TableCellContentRepresentable] = [
            DateContent(title: "Период: начало", date: self.selectedStartDate, dateType: DateType.startDate),
            DateContent(title: "Период: конец", date: self.selectedEndDate, dateType: DateType.endDate),
            SortContent(title: "Сортировка", value: sortBy),
            TotalAmountContent(title: "Сумма", value: "Загрузка...")
        ]
        self.sections.append(TableSection(id: "Config", data: initialConfigData))
        self.sections.append(TableSection(id: "Transactions", title: "Операции"))
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
        
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        do {
            let fetchedTransactions = try await service.fetchTransactionsByDirection(
                from: selectedStartDate,
                to: selectedEndDate,
                direction: direction,
                sortBy: sortBy
            )
            await MainActor.run {
                self.updateUI(with: fetchedTransactions)
            }
        } catch {
            print("Ошибка загрузки данных: \(error)")
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
            sectionToUpdate.data = convert(data: data)
            sections[index] = sectionToUpdate
            tableView.reloadSections(IndexSet(integer: index), with: .automatic)
        }
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
            service: MockTransactionsService()
        )
            .background(Color("BackgroundColor"))
    }
}
