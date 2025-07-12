import UIKit

protocol TableCellContentRepresentable {
    func configure(cell: UITableViewCell, at indexPath: IndexPath)
    var reuseIdentifier: String { get }
}
