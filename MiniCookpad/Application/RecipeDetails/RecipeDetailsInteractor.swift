class RecipeDetailsInteractor: RecipeDetailsInteractorProtocol {
    private let recipeDataStore: RecipeDataStoreProtocol
    init(recipeDataStore: RecipeDataStoreProtocol) {
        self.recipeDataStore = recipeDataStore
    }

    func fetchRecipe(recipeID: String, completion: @escaping ((Result<RecipeDetailsRecipe, Error>) -> Void)) {
        recipeDataStore.fetchRecipe(recipeID: recipeID) { result in
            switch result {
            case let .success(firestoreRecipe):
                let recipe = RecipeDetailsRecipe(title: firestoreRecipe.title, imagePath: firestoreRecipe.imagePath, steps: firestoreRecipe.steps)
                completion(.success(recipe))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
