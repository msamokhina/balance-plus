import UIKit

struct TransactionContent: TableCellContentRepresentable {
    let iconName: String
    let title: String
    let subtitle: String?
    let percentage: String
    let amount: String

    let reuseIdentifier: String = "TransactionCell"

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let customCell = cell as? TransactionCell else {
            fatalError("Expected TransactionCell for TransactionContent, but got \(type(of: cell))")
        }
        
        customCell.configure(
            iconName: iconName,
            title: title,
            subtitle: subtitle,
            percentage: percentage,
            amount: amount
        )
    }
}

class TransactionCell: UITableViewCell {
    let emojiView: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.2)
        label.layer.cornerRadius = 13
        label.layer.masksToBounds = true
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = UIColor.secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var titleBottomConstraintWithSubtitle: NSLayoutConstraint!
    private var titleBottomConstraintWithoutSubtitle: NSLayoutConstraint!
    
    private var subtitleTopConstraint: NSLayoutConstraint!
    private var subtitleBottomConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(emojiView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(percentageLabel)
        contentView.addSubview(amountLabel)

        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 16
        let smallPadding: CGFloat = 8
        let emojiSize: CGFloat = 26
        
        NSLayoutConstraint.activate([
            emojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emojiView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiView.widthAnchor.constraint(equalToConstant: emojiSize),
            emojiView.heightAnchor.constraint(equalToConstant: emojiSize),

            titleLabel.leadingAnchor.constraint(equalTo: emojiView.trailingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentageLabel.leadingAnchor, constant: -smallPadding),

            subtitleLabel.leadingAnchor.constraint(equalTo: emojiView.trailingAnchor, constant: padding),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -smallPadding),

            percentageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: smallPadding),
            percentageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            amountLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 2),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            amountLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -smallPadding)
        ])
        
        titleBottomConstraintWithSubtitle = titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -2)
        subtitleTopConstraint = subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        subtitleBottomConstraint = subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -smallPadding)

        titleBottomConstraintWithoutSubtitle = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -smallPadding)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: smallPadding),
            titleBottomConstraintWithSubtitle,
            subtitleTopConstraint,
            subtitleBottomConstraint
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiView.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        percentageLabel.text = nil
        amountLabel.text = nil
        
        subtitleLabel.isHidden = false
        titleBottomConstraintWithoutSubtitle.isActive = false
        titleBottomConstraintWithSubtitle.isActive = false
        subtitleTopConstraint.isActive = false
        subtitleBottomConstraint.isActive = false
    }
    
    func configure(iconName: String, title: String, subtitle: String?, percentage: String, amount: String) {
        emojiView.text = iconName
        titleLabel.text = title
        percentageLabel.text = percentage
        amountLabel.text = amount
        
        if let subtitleText = subtitle, !subtitleText.isEmpty {
            subtitleLabel.text = subtitleText
            subtitleLabel.isHidden = false

            titleBottomConstraintWithoutSubtitle.isActive = false
            titleBottomConstraintWithSubtitle.isActive = true
            subtitleTopConstraint.isActive = true
            subtitleBottomConstraint.isActive = true
        } else {
            subtitleLabel.text = nil
            subtitleLabel.isHidden = true

            titleBottomConstraintWithSubtitle.isActive = false
            titleBottomConstraintWithoutSubtitle.isActive = true
            subtitleTopConstraint.isActive = false
            subtitleBottomConstraint.isActive = false
        }
    }
}
