import Foundation

struct OilchangelogEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date = Date()
    var mileage: String = ""
    var oilType: String = ""
    var note: String = ""
}
