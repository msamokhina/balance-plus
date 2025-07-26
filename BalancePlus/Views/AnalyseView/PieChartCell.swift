import UIKit
import PieChart

struct PieChartContent: TableCellContentRepresentable {
    let entities: [Entity]
    let reuseIdentifier: String = "PieChartCell"
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let pieChartCell = cell as? PieChartCell else {
            fatalError("Expected pieChartCell for pieChartContent, but got \(type(of: cell))")
        }
        pieChartCell.configure(with: entities)
    }
}

class PieChartCell: UITableViewCell {
    var pieChartView: PieChartView = {
        let view = PieChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(pieChartView)
        
        setupConstraints()
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pieChartView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pieChartView.widthAnchor.constraint(equalToConstant: 200),
            pieChartView.heightAnchor.constraint(equalToConstant: 200),
            
            pieChartView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pieChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with entities: [Entity]) {
        pieChartView.entities = entities
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pieChartView.entities = []
    }
}
