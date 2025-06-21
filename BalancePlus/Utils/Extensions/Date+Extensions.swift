import Foundation

extension Date {
    func endOfDay() -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func startOfDayMonthAgo() -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.month = -1
        let dayMonthAgo = calendar.date(byAdding: dateComponents, to: self)!

        return Calendar.current.startOfDay(for: dayMonthAgo)
    }
    
    func formattedDayMonthYear() -> String {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let dateYear = calendar.component(.year, from: self)

        let formatter = DateFormatter()

        if dateYear != currentYear {
            formatter.dateFormat = "d MMMM yyyy"
        } else {
            formatter.dateFormat = "d MMMM"
        }

        return formatter.string(from: self)
    }
}
