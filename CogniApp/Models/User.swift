struct User: Identifiable, Codable {
    let id: String
    let name: String
    let surname: String
    let surname2: String?
    let email: String
    let age: Int?
}