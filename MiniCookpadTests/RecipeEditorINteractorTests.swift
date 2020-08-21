import XCTest
@testable import MiniCookpad

class MockImageDataStore: ImageDataStoreProtocol {
    var createImageResult: (Result<ImagePath, Error>)!
    func createImage(imageData: Data, completion: @escaping ((Result<ImagePath, Error>) -> Void)) {
        completion(createImageResult)
    }
}

class MockRecipeDataStore: RecipeDataStoreProtocol {
    var createRecipeResult: (Result<Void, Error>)!
    func createRecipe(title: String, steps: [String], imagePath: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        completion(createRecipeResult)
    }

    // この2つは今回使わない
    func fetchAllRecipes(completion: @escaping ((Result<[FirestoreRecipe], Error>) -> Void)) {
        fatalError()
    }
    func fetchRecipe(recipeID: String, completion: @escaping ((Result<FirestoreRecipe, Error>) -> Void)) {
        fatalError()
    }
}

class RecipeEditorInteractorTests: XCTestCase {
    var imageDataStore: MockImageDataStore!
    var recipeDataStore: MockRecipeDataStore!

    // テストのたびに Mock の状態をリセットする
    override func setUp() {
        super.setUp()
        imageDataStore = MockImageDataStore()
        recipeDataStore = MockRecipeDataStore()
    }

    func testCreateRecipeSuccess() {
        let imagePath = ImagePath(path: "dummy_path")
        imageDataStore.createImageResult = .success(imagePath)
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
        let image = #imageLiteral(resourceName: "recipe_image")
        interactor.createRecipe(title: "title", steps: ["steps"], image: image) { result in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure:
                XCTFail()
            }
        }
    }

    func testCreateRecipe_CreateImageFailure() {
        let error = NSError(domain: "", code: 11111111, userInfo: nil)
        imageDataStore.createImageResult = .failure(error)
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
        let image = #imageLiteral(resourceName: "recipe_image")
        interactor.createRecipe(title: "title", steps: ["steps"], image: image) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(resultError):
                switch resultError {
                case .creationError:
                    XCTAssert(true)
                case .validationError:
                    XCTFail()
                }
            }
        }
    }

    func testCreateRecipe_TitleIsNil() {
        let imagePath = ImagePath(path: "dummy_path")
        imageDataStore.createImageResult = .success(imagePath)
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
        let image = #imageLiteral(resourceName: "recipe_image")
        interactor.createRecipe(title: nil, steps: ["steps"], image: image) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(resultError):
                switch resultError {
                case .creationError:
                    XCTFail()
                case .validationError:
                    XCTAssert(true)
                }
            }
        }
    }

    func testCreateRecipe_StepsContainsEmptyString() {
        let imagePath = ImagePath(path: "dummy_path")
        imageDataStore.createImageResult = .success(imagePath)
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
        let image = #imageLiteral(resourceName: "recipe_image")
        interactor.createRecipe(title: nil, steps: ["step1", "", "step2"], image: image) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(resultError):
                switch resultError {
                case .creationError:
                    XCTFail()
                case .validationError:
                    XCTAssert(true)
                }
            }
        }
    }

    func testCreateRecipe_StepsContainsEmoji() {
        let imagePath = ImagePath(path: "dummy_path")
        imageDataStore.createImageResult = .success(imagePath)
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
        let image = #imageLiteral(resourceName: "recipe_image")
        interactor.createRecipe(title: nil, steps: ["step1", "📱"], image: image) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(resultError):
                switch resultError {
                case .creationError:
                    XCTFail()
                case .validationError:
                    XCTAssert(true)
                }
            }
        }
    }
}
