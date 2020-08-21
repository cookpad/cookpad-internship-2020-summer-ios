import Firebase

protocol RecipeDataStoreProtocol {
    func fetchAllRecipes(completion: @escaping ((Result<[FirestoreRecipe], Error>) -> Void))
}

struct RecipeDataStore: RecipeDataStoreProtocol {
    private let collection: CollectionReference

    init(db: Firestore = Firestore.firestore()) {
        self.collection = db.collection("recipes")
    }

    func fetchAllRecipes(completion: @escaping ((Result<[FirestoreRecipe], Error>) -> Void)) {
        collection.order(by: "createdAt", descending: true).getDocuments() { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let recipe = querySnapshot!.documents
                    // 取得したデータを Entity に変換
                    .compactMap { try? $0.data(as: FirestoreRecipe.self)  }
                completion(.success(recipe))
            }
        }
    }
}
