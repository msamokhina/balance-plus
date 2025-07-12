import UIKit

struct TotalAmountContent: TableCellContentRepresentable {
    let title: String
    let value: String
    
    let reuseIdentifier: String = "TotalAmountCell"
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let totalAmountCell = cell as? TotalAmountCell else {
            fatalError("Expected TotalAmountCell for TotalAmountContent, but got \(type(of: cell))")
        }
        totalAmountCell.textLabel?.text = title
        totalAmountCell.detailTextLabel?.text = value
    }
}

class TotalAmountCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.detailTextLabel?.textColor = .label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
}
