import Foundation
import SwiftUI
import UIKit

// MARK: - Entity

public struct Entity {
    public let value: Decimal
    public let label: String

    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

// MARK: - Colors Constants

extension UIColor {
    static let pieChartColor1 = UIColor(red: 0.1647, green: 0.9098, blue: 0.5059, alpha: 1.0)
    static let pieChartColor2 = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
    static let pieChartColor3 = UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0)
    static let pieChartColor4 = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
    static let pieChartColor5 = UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0)
    static let pieChartColorOther = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
}

// MARK: - PieChartView

public class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
    }

    private let segmentColors: [UIColor] = [
        .pieChartColor1,
        .pieChartColor2,
        .pieChartColor3,
        .pieChartColor4,
        .pieChartColor5,
        .pieChartColorOther
    ]

    private func processEntitiesForDisplay(entities: [Entity]) -> [Entity] {
        guard !entities.isEmpty else { return [] }
        let sortedEntities = entities.sorted { $0.value > $1.value }

        let top5 = Array(sortedEntities.prefix(5))
        let remaining = sortedEntities.dropFirst(5)

        if remaining.isEmpty {
            return top5
        } else {
            let othersValue = remaining.reduce(0) { $0 + $1.value }
            let othersEntity = Entity(value: othersValue, label: "Остальные")
            return top5 + [othersEntity]
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let displayEntities = processEntitiesForDisplay(entities: self.entities)

        let totalValue = displayEntities.reduce(0) { $0 + $1.value }
        guard totalValue > 0 else { return }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * 0.8
        let innerRadius = radius * 0.9

        var currentAngle: CGFloat = 0.0

        for (index, entity) in displayEntities.enumerated() {
            let percentage = CGFloat(truncating: entity.value / totalValue as NSDecimalNumber)
            let angle = percentage * 360.0
            let startAngle = currentAngle
            let endAngle = currentAngle + angle

            let color = segmentColors[index]
            context.setFillColor(color.cgColor)
            
            let path = UIBezierPath()
            let startPointOuter = CGPoint(
                x: center.x + radius * cos(startAngle.degreesToRadians),
                y: center.y + radius * sin(startAngle.degreesToRadians)
            )
            path.move(to: startPointOuter)
            
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: startAngle.degreesToRadians,
                        endAngle: endAngle.degreesToRadians,
                        clockwise: true)

            let endPointInner = CGPoint(
                x: center.x + innerRadius * cos(endAngle.degreesToRadians),
                y: center.y + innerRadius * sin(endAngle.degreesToRadians)
            )
            path.addLine(to: endPointInner)
            
            path.addArc(withCenter: center,
                        radius: innerRadius,
                        startAngle: endAngle.degreesToRadians,
                        endAngle: startAngle.degreesToRadians,
                        clockwise: false)


            path.close()
            path.fill()

            currentAngle = endAngle
        }
        
        drawLegend(in: rect, center: center, radius: radius, entities: displayEntities)
    }

    private func drawLegend(in rect: CGRect, center: CGPoint, radius: CGFloat, entities: [Entity]) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let legendItemHeight: CGFloat = 12
        let legendSymbolSize: CGFloat = 8
        let textPadding: CGFloat = 5
        let totalLegendHeight = CGFloat(entities.count) * legendItemHeight

        var currentY = center.y - totalLegendHeight / 2
        let totalValue = entities.reduce(0) { $0 + $1.value }

        for (index, entity) in entities.enumerated() {
            let color = segmentColors[index]

            // Цветной круг
            let symbolRect = CGRect(x: center.x - radius / 2,
                                    y: currentY + (legendItemHeight - legendSymbolSize) / 2,
                                    width: legendSymbolSize,
                                    height: legendSymbolSize)
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: symbolRect)

            let percentage = CGFloat(truncating: entity.value / totalValue * 100 as NSDecimalNumber)
                    
            // Форматируем Decimal в String без лишних знаков после запятой, если они .0
            // Оставляем один знак, если есть дробная часть
            let percentageString: String
            if percentage.truncatingRemainder(dividingBy: 1) == 0 {
                percentageString = String(format: "%.0f", percentage)
            } else {
                percentageString = String(format: "%.1f", percentage)
            }

            let text = "\(percentageString)% \(entity.label)"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8),
                .paragraphStyle: paragraphStyle
            ]

            let textRect = CGRect(x: symbolRect.maxX + textPadding,
                                  y: currentY,
                                  width: radius * 1.3,
                                  height: legendItemHeight)
            (text as NSString).draw(in: textRect, withAttributes: attributes)

            currentY += legendItemHeight
        }
    }
}


// MARK: - Helper Extension for Degrees to Radians Conversion

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
}
