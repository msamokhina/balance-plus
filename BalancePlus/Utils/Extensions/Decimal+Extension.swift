import Foundation

extension Decimal {
    // TODO: придумать что-то полаконичнее
    func percentageString(from totalAmount: Decimal) -> String {
        guard totalAmount != 0 else {
            return "0%"
        }

        let rawPercentage = (self / totalAmount) * 100

        let handler = NSDecimalNumberHandler(
            roundingMode: .up,
            scale: 1,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )

        let roundedPercentageDecimal = (rawPercentage as NSDecimalNumber).rounding(accordingToBehavior: handler) as Decimal
        
        let integerPart = NSDecimalNumber(decimal: roundedPercentageDecimal).intValue
        let integerDecimal = Decimal(integerPart)

        if roundedPercentageDecimal == integerDecimal {
            return String(describing: integerDecimal) + "%"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            formatter.decimalSeparator = "."
            
            if let formattedString = formatter.string(from: roundedPercentageDecimal as NSDecimalNumber) {
                return formattedString + "%"
            } else {
                return "\(roundedPercentageDecimal)%"
            }
        }
    }
}
