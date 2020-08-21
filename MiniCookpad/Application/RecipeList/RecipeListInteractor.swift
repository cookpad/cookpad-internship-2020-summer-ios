class RecipeListInteractor: RecipeListInteractorProtocol {
    private let recipeDataStore: RecipeDataStoreProtocol
    private let userDataStore: UserDataStoreProtocol
    init(recipeDataStore: RecipeDataStoreProtocol, userDataStore: UserDataStoreProtocol) {
        self.recipeDataStore = recipeDataStore
        self.userDataStore = userDataStore
    }
    
    func fetchAllRecipes(completion: @escaping ((Result<[RecipeListRecipe], Error>) -> Void)) {
        recipeDataStore.fetchAllRecipes { result in
            switch result {
            case let .success(firestoreRecipes):
                let recipes: [RecipeListRecipe] = firestoreRecipes.compactMap { firestoreRecipe in
                    if let recipeID = firestoreRecipe.id {
                        return RecipeListRecipe(id: recipeID, title: firestoreRecipe.title, imagePath: firestoreRecipe.imagePath, steps: firestoreRecipe.steps)
                    } else {
                        return nil
                    }
                }
                completion(.success(recipes))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func hasUserID() -> Bool {
        return userDataStore.currentUserID != nil
    }
}
