import Foundation
// Firebase を Codable で利用できるライブラリ
import FirebaseFirestoreSwift

struct FirestoreRecipe: Codable, Equatable {
    /// recipes/:id の id
    @DocumentID var id: String?
    var title: String
    var imagePath: String
    var steps: [String]
    var createdAt = Date()
}
