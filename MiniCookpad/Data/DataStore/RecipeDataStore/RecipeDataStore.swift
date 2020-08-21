import Firebase

protocol RecipeDataStoreProtocol {
    func fetchAllRecipes(completion: @escaping ((Result<[FirestoreRecipe], Error>) -> Void))
    func fetchRecipe(recipeID: String, completion: @escaping ((Result<FirestoreRecipe, Error>) -> Void))
    func createRecipe(title: String, steps: [String], imagePath: String, completion: @escaping ((Result<Void, Error>) -> Void))
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

    func fetchRecipe(recipeID: String, completion: @escaping ((Result<FirestoreRecipe, Error>) -> Void)) {
        collection.document(recipeID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let recipe = try! snapshot!.data(as: FirestoreRecipe.self)!
                completion(.success(recipe))
            }
        }
    }

    func createRecipe(title: String, steps: [String], imagePath: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        let recipe = FirestoreRecipe(title: title, imagePath: imagePath, steps: steps)
        _ = try! collection.addDocument(from: recipe) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
