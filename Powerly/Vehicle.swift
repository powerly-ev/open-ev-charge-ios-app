import Foundation

struct Vehicle: Codable {
    let id: Int
    var title: String
    let make: Make
    let model: VehicleModel
    let year: Int
    let color: String
    let fuelType: String
    let chargingConnector: Connector?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case make
        case model
        case year
        case color
        case fuelType = "fuel_type"
        case chargingConnector = "charging_connector"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        make = try container.decode(Make.self, forKey: .make)
        model = try container.decode(VehicleModel.self, forKey: .model)
        if let strYear = try? container.decodeIfPresent(String.self, forKey: .year) {
            year = Int(strYear) ?? 0
        } else {
            year = (try? container.decodeIfPresent(Int.self, forKey: .year)) ?? 0
        }
        color = try container.decode(String.self, forKey: .color)
        fuelType = try container.decode(String.self, forKey: .fuelType)
        chargingConnector = try? container.decode(Connector.self, forKey: .chargingConnector)
    }
}
