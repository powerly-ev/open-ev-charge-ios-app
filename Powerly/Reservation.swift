import Foundation

struct Reservation: Codable {
    let chargePoint: ChargePoint?
    let quantity: String
    let id: Int
    let expiresAt: String
    let createdAt: String
    let feePaid: Double
    let userId: Int
    let reservationDatetime: String
    
    enum CodingKeys: String, CodingKey {
        case chargePoint = "charge_point"
        case quantity
        case id
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case feePaid = "fee_paid"
        case userId = "user_id"
        case reservationDatetime = "reservation_datetime"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        chargePoint = try? container.decodeIfPresent(ChargePoint.self, forKey: .chargePoint)
        quantity = try container.decode(String.self, forKey: .quantity)
        id = try container.decode(Int.self, forKey: .id)
        expiresAt = try container.decode(String.self, forKey: .expiresAt)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        if let strFeePaid = try? container.decodeIfPresent(String.self, forKey: .feePaid) {
            feePaid = Double(strFeePaid) ?? 0
        } else {
            feePaid = (try? container.decodeIfPresent(Double.self, forKey: .feePaid)) ?? 0
        }
        if let strUserId = try? container.decodeIfPresent(String.self, forKey: .userId) {
            userId = Int(strUserId) ?? 0
        } else {
            userId = (try? container.decodeIfPresent(Int.self, forKey: .userId)) ?? 0
        }
        reservationDatetime = try container.decode(String.self, forKey: .reservationDatetime)
    }
}
