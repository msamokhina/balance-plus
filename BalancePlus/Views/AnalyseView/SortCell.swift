import UIKit

struct SortContent: TableCellContentRepresentable {
    let title: String
    var value: TransactionsSortType
    let reuseIdentifier: String = "SortCell"
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let sortCell = cell as? SortCell else {
            fatalError("Expected sortCell for sortContent, but got \(type(of: cell))")
        }
        sortCell.textLabel?.text = title
        sortCell.menuButton.setTitle(value.name, for: .normal)
    }
}

protocol SortCellDelegate: AnyObject {
    func sortCell(_ cell: SortCell, didChangeSortType newType: TransactionsSortType)
}

class SortCell: UITableViewCell {
    weak var delegate: SortCellDelegate?
    var currentSortType: TransactionsSortType? {
        didSet {
            setupMenu()
        }
    }
    
    let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.showsMenuAsPrimaryAction = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(menuButton)
        
        setupConstraints()
        
        self.selectionStyle = .none
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        setupMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMenu() {
        let menuItems = TransactionsSortType.allCases.map { [weak self] sortType in
            UIAction(title: sortType.name, handler: { _ in
                self?.delegate?.sortCell(self!, didChangeSortType: sortType)
                self?.menuButton.setTitle(sortType.name, for: .normal)
            })
        }
        let menu = UIMenu(title: "", children: menuItems)
        menuButton.menu = menu
    }

    private func setupConstraints() {
        let outerPadding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerPadding),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        menuButton.setTitle(nil, for: .normal)
    }
}
