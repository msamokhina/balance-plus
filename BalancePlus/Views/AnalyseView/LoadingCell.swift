import UIKit

struct LoadingContent: TableCellContentRepresentable {
    var reuseIdentifier: String = "LoadingCell"
    var title: String = "Загрузка операций..."

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        if let loadingCell = cell as? LoadingCell {
            loadingCell.configure(with: self)
        }
    }
}

class LoadingCell: UITableViewCell {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let loadingLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(loadingLabel)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        activityIndicator.startAnimating()
        loadingLabel.textAlignment = .center
    }

    func configure(with content: LoadingContent) {
        loadingLabel.text = content.title
        activityIndicator.startAnimating()
    }
}
