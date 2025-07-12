import UIKit

struct DateContent: TableCellContentRepresentable {
    let title: String
    let date: Date
    let dateType: DateType
    
    let reuseIdentifier: String = "DateCell"
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let dateCell = cell as? DateCell else {
            fatalError("Expected DateCell for DateContent, but got \(type(of: cell))")
        }
        dateCell.textLabel?.text = title
        dateCell.datePicker.date = date
        
        dateCell.dateType = dateType
    }
}

enum DateType {
    case startDate
    case endDate
}

protocol DateCellDelegate: AnyObject {
    func dateCellChange(newDate: Date, for dateType: DateType)
}

class DateCell: UITableViewCell {
    weak var delegate: DateCellDelegate?
    var dateType: DateType?
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = UIColor(named: "AccentColor")
        datePicker.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.2)
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true
        datePicker.addTarget(self, action: #selector(handleDateChange), for: .valueChanged)
        
        return datePicker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(datePicker)
                
        setupConstraints()
        
        self.selectionStyle = .none
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        let outerPadding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerPadding),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        
        self.delegate = nil
        self.dateType = nil
    }
    
    @objc private func handleDateChange() {
        if let type = dateType {
            delegate?.dateCellChange(newDate: self.datePicker.date, for: type)
        }
    }
}
