import Foundation
import UIKit

class RecipeEditorInteractor: RecipeEditorInteractorProtocol {
    let imageDataStore: ImageDataStoreProtocol
    let recipeDataStore: RecipeDataStoreProtocol
    init(imageDataStore: ImageDataStoreProtocol, recipeDataStore: RecipeDataStoreProtocol) {
        self.imageDataStore = imageDataStore
        self.recipeDataStore = recipeDataStore
    }

    func createRecipe(title: String?, steps: [String?], image: UIImage?, completion: @escaping ((Result<Void, RecipeEditorError>) -> Void)) {
        let result = Self.validate(title: title, steps: steps, imageData: image?.jpegData(compressionQuality: 0.1))

        let title: String
        let steps: [String]
        let imageData: Data
        switch result {
        case let .success((resultTitle, resultSteps, resultImageData)):
            title = resultTitle
            steps = resultSteps
            imageData = resultImageData
        case let .failure(error):
            completion(.failure(error))
            return
        }

        imageDataStore.createImage(imageData: imageData, completion: { [weak self] imageResult in
            switch imageResult {
            case let .success(imagePath):
                // createImage が成功したら createRecipe を実行
                self?.recipeDataStore.createRecipe(title: title, steps: steps, imagePath: imagePath.path) { recipeResult in
                    switch recipeResult {
                    case .success:
                        completion(.success(()))
                    case let .failure(error):
                        completion(.failure(.creationError(error)))
                    }
                }
            case let .failure(error):
                completion(.failure(.creationError(error)))
            }
        })
    }

    private static func validate(title: String?, steps: [String?], imageData: Data?) -> Result<(title: String, steps: [String], imageData: Data), RecipeEditorError> {
        guard let imageData = imageData  else {
            return .failure(.validationError)
        }

        // 空文字ではないかチェック
        guard let title = title else {
            return .failure(.validationError)
        }

        let steps = steps.compactMap { $0 }
        if steps.isEmpty, title.isEmpty {
            return .failure(.validationError)
        }
        if containsEmoji(text: title) || (steps.map { Self.containsEmoji(text: $0) }).contains(true) {
            return .failure(.validationError)
        }

        return .success((title: title, steps: steps, imageData: imageData))
    }

    private static func containsEmoji(text: String) -> Bool {
        let emojis = text.unicodeScalars.filter { $0.properties.isEmoji }
        return !emojis.isEmpty
    }
}
