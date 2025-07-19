import UIKit

struct ErrorContent: TableCellContentRepresentable {
    let reuseIdentifier: String = "ErrorCell"
    let message: String
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        if let errorCell = cell as? ErrorCell {
            errorCell.configure(with: self)
        }
    }
}

class ErrorCell: UITableViewCell {
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            errorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        selectionStyle = .none
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with content: ErrorContent) {
        errorLabel.text = content.message
    }
}

struct EmptyStateContent: TableCellContentRepresentable {
    let reuseIdentifier: String = "EmptyStateCell"
    let message: String
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        if let emptyCell = cell as? EmptyStateCell {
            emptyCell.configure(with: self)
        }
    }
}

class EmptyStateCell: UITableViewCell {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        selectionStyle = .none
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with content: EmptyStateContent) {
        messageLabel.text = content.message
    }
}
