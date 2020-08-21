# 投稿機能

できているとこまでコミットしておきましょう。

```shell
git commit -am "part2 finished"
```

part2 が完了できなかった人は part3 ブランチを checkout してください。

```
git checkout part3
```

レシピ投稿機能を作成しましょう。
どうやら、開発途中で RecipeEditorViewController.swift の View だけ作られていて、投稿のコア機能はまだ開発されていないようです。

* 機能
  * 写真、タイトル、手順の3つの入力がある
  * 写真投稿、レシピ登録の2つの処理がある
    * レシピに写真が必須なので、写真投稿が成功してからレシピ登録を行う(2つのAPIを直列して実行)
  * 入力のバリデーション
    * 写真は必須
    * タイトルは1文字以上
    * 手順は1つ以上入力されていないといけない
    * 絵文字は入力できない

バリデーションはビジネスロジックに該当するので、interactor に記述します。  
レシピ一覧画面、レシピ詳細画面の時と同じように、DataStore や Contract を作成しアーキテクチャに則った形で実装してみましょう。今回は自分でファイル作成からやってみてください。

#### 注意事項

※投稿時に写真、タイトル、手順のどれかが入力されていないレシピデータが作成された場合、レシピ一覧画面には表示されないのでご注意ください。

#### レシピ一覧画面にレシピ投稿画面の導線を追加

RecipeList 画面を以下のように修正し、実行してください。
画面右上に「レシピを投稿する」ボタンが出てきて、それをタップするとレシピ投稿画面が開きます。

```diff
// MiniCookpad/Application/RecipeList/RecipeListContract.swift
 protocol RecipeListPresenterProtocol: AnyObject {
     func fetchRecipes()
     func openRecipeDetails(recipeID: String)
+    func openRecipeEditor()
 }

 protocol RecipeListWireframeProtocol: AnyObject {
     func openRecipeDetails(recipeID: String)
+    func openRecipeEditor()
 }
```

```diff
// MiniCookpad/Application/RecipeList/RecipeListPresenter.swift
     func openRecipeDetails(recipeID: String) {
         wireframe.openRecipeDetails(recipeID: recipeID)
     }
+
+    func openRecipeEditor() {
+        wireframe.openRecipeEditor()
+    }
 }
```

```diff
// MiniCookpad/Application/RecipeList/RecipeListViewController.swift

         setUpDummyDataButton()

+        let postButton = UIBarButtonItem(title: "レシピ投稿する", style: .plain, target: self, action: #selector(didTapPostRecipe))
+        navigationItem.rightBarButtonItem = postButton
+
         title = "レシピ一覧"

         view = tableView

@@ -47,6 +50,10 @@ class RecipeListViewController: UIViewController, RecipeListViewProtocol {
         refreshControl.beginRefreshing()
         presenter.fetchRecipes()
     }
+
+    @objc private func didTapPostRecipe() {
+        presenter.openRecipeEditor()
+    }
 }
```

```diff
// MiniCookpad/Application/RecipeList/RecipeListWireframe.swift
         let vc = RecipeDetailsViewBuilder.build(with: recipeID)
         viewController.navigationController?.pushViewController(vc, animated: true)
     }
+
+    func openRecipeEditor() {
+        let vc = RecipeEditorViewController()
+        let nav = UINavigationController(rootViewController: vc)
+        nav.modalPresentationStyle = .fullScreen
+        viewController.present(nav, animated: true, completion: nil)
+    }
 }
```

#### 絵文字の validation

文字列に絵文字が含まれているかは、以下のコードを参考にしてください。

```swift
// text に emoji があったら true になる
private static func containsEmoji(text: String) -> Bool {
    let emojis = text.unicodeScalars.filter { $0.properties.isEmoji }
    return !emojis.isEmpty
}
```

#### 画像の投稿

Cloud Firestore に画像を投稿するには、以下のコードを参考にしてください。

```swift
import FirebaseStorage
import Firebase

let imageData = UIImage()
guard let imageData = postImage?.jpegData(compressionQuality: 0.1) else { return }
let storageReference = Storage.storage().reference()
let fileName = "\(UUID()).jpg"
let imageRef = storageReference.child(fileName)
let metaData = StorageMetadata()
metaData.contentType = "image/jpg"

_ = imageRef.putData(imageData, metadata: metaData) { metadata, error in
    if let error = error {
      // error
    } else {
      // success
    }
}
```

#### レシピ投稿

レシピ投稿する時は以下のコードを参考にしてください。

```swift
let recipe = FirestoreRecipe(title: title, imagePath: imagePath, steps: steps)
_ = try! collection.addDocument(from: recipe) { error in
    if let error = error {
      // error
    } else {
      // success
    }
}
```

## ヒント

<details>
<summary>ヒント1</summary>

画像の登録は ImageDataStore.swift というファイル名で、RecipeDataStore とは別ファイルで作成します。

```swift
// ImageDataStore.swift
import Foundation

protocol ImageDataStoreProtocol {
    func createImage(imageData: Data, completion: @escaping ((Result<ImagePath, Error>) -> Void))
}
```

画像の作成後、レシピ情報の登録のために path が必要です。createImage が成功したら、path 情報を返却しましょう。

```swift
// ImagePath.swift

struct ImagePath {
    var path: String
}
```

レシピ登録は RecipeDataStore に `createRecipe` というメソッドを生やします。レシピ登録に必要な情報を引数で受け取ります。
`createRecipe` では title, steps, imagePath を受け取り Firestore に登録するだけです。

```diff
// RecipeDataStore
 protocol RecipeDataStoreProtocol {
     func fetchAllRecipes(completion: @escaping ((Result<[Recipe], Error>) -> Void))
     func fetchRecipe(recipeID: String, completion: @escaping ((Result<Recipe, Error>) -> Void))
+    func createRecipe(title: String, steps: [String], imagePath: String, completion: @escaping ((Result<Void, Error>) -> Void))
 }
```

Interactor では、createImage で画像の登録が完了してから、その ImagePath を使って `createRecipe` を実行する必要があります。

</details>

<br>

<details>
<summary>ヒント2</summary

それぞれの DataStore の実装はこのようになります。

```swift
// ImageDataStore.swift
import Foundation
import FirebaseStorage
import Firebase

protocol ImageDataStoreProtocol {
    func createImage(imageData: Data, completion: @escaping ((Result<ImagePath, Error>) -> Void))
}

struct ImageDataStore: ImageDataStoreProtocol {
    private let storageReference: StorageReference

    init(storageReference: StorageReference = Storage.storage().reference()) {
        self.storageReference = storageReference
    }

    func createImage(imageData: Data, completion: @escaping ((Result<ImagePath, Error>) -> Void)) {
        let fileName = "\(UUID()).jpg"
        let imageRef = storageReference.child(fileName)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        _ = imageRef.putData(imageData, metadata: metaData) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let imagePath = ImagePath(path: fileName)
                completion(.success(imagePath))
            }
        }
    }
}
```

```swift
// MiniCookpad/Data/DataStore/RecipeDataStore.swift

 protocol RecipeDataStoreProtocol {
     func fetchAllRecipes(completion: @escaping ((Result<[Recipe], Error>) -> Void))
     func fetchRecipe(recipeID: String, completion: @escaping ((Result<Recipe, Error>) -> Void))
+    func createRecipe(title: String, steps: [String], imagePath: String, completion: @escaping ((Result<Void, Error>) -> Void))
 }

 struct RecipeDataStore: RecipeDataStoreProtocol {
@@ -35,4 +36,15 @@ struct RecipeDataStore: RecipeDataStoreProtocol {
             }
         }
     }
+
+    func createRecipe(title: String, steps: [String], imagePath: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
+        let recipe = FirestoreRecipe(title: title, imagePath: imagePath, steps: steps)
+        _ = try! collection.addDocument(from: recipe) { error in
+            if let error = error {
+                completion(.failure(error))
+            } else {
+                completion(.success(()))
+            }
+        }
+    }
 }
```

</details>

<br>

<details>
<summary>ヒント3</summary>

Interactor, Presenter の処理の流れは以下のようになります。  
エラーが複数種類になるため、 `enum RecipeEditorError` を作成すると良いです。

- Interactor
  - Presenter から渡された情報が正しいか検証します
    - 絵文字が含まれていないか、タイトル、ステップ、画像が入力されているか検証
    - 問題があれば `completion(.failure(RecipeEditorError.validationError))` を実行します
  - 検証が問題なければ、 ImageDataStore を使い画像を登録し、その次に RecipeDataStore を使いレシピの登録をします
    - 成功したら `completion(.success())`、失敗したら `completion(.failure(RecipeEditorError.creationError(error)))` を実行します
- Presenter
  - View から title, steps, image を受け取ります
  - interactor の createRecipe メソッドを実行します
    - 成功したら `view.showComplete()` を実行します
    - 失敗したらエラーの型をみて `view.showValidationError()` もしくは `view.showError(error)` を実行します

```swift
// RecipeEdtiorError.swift
enum RecipeEditorError: Error {
    case validationError
    case creationError(Error)
}
```

そして、それぞれの Protocol, ViewBuilder はこのようになります。

```swift
// RecipeEditorContract.swift
import Foundation
import UIKit

protocol RecipeEditorViewProtocol: AnyObject {
    func showValidationError()
    func showError(_ error: Error)
    func showComplete()
}

protocol RecipeEditorPresenterProtocol: AnyObject {
    func createRecipe(title: String?, steps: [String?], image: UIImage?)
    func close()
}

protocol RecipeEditorInteractorProtocol: AnyObject {
    func createRecipe(title: String?, steps: [String?], image: UIImage?, completion: @escaping ((Result<Void, RecipeEditorError>) -> Void))
}

protocol RecipeEditorWireframeProtocol: AnyObject {
    func close()
}
```

```swift
// RecipeEditorViewBuilder.swift
struct RecipeEditorViewBuilder {
    static func build() -> RecipeEditorViewController {
        let viewController = RecipeEditorViewController()
        let interactor = RecipeEditorInteractor(imageDataStore: ImageDataStore(), recipeDataStore: RecipeDataStore())
        let wireframe = RecipeEditorWireframe(viewController: viewController)
        let presenter = RecipeEditorPresenter(view: viewController, interactor: interactor, wireframe: wireframe)
        viewController.inject(presenter: presenter)

        return viewController
    }
}
```
</details>

<br>

<details>
<summary>ヒント4</summary>

Interactor はこのようになります。  
createRecipe の中で、Presenter から受けとった情報に問題がないかを確認し、問題がなければ画像の作成とレシピの作成をします。  
validate は、検証結果が正しければ `.success` が返り、正しくない場合は `.failure` が返るようにしています。項目が増えたり、もっと複雑になったら `RecipeEdtiorValidation` のように独自クラスを作って切り出すと良いですね。

```swift
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
```
</details>

<br>

<details>
<summary>ヒント5</summary>

Presenter はこのようになります。  
文字列の検証は Interactor で行い、結果を元に view に命令を出しています。

```swift
import Foundation
import UIKit

final class RecipeEditorPresenter: RecipeEditorPresenterProtocol {
    private weak var view: RecipeEditorViewProtocol!
    private let interactor: RecipeEditorInteractorProtocol
    private let wireframe: RecipeEditorWireframeProtocol

    init(view: RecipeEditorViewProtocol, interactor: RecipeEditorInteractorProtocol, wireframe: RecipeEditorWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }

    func createRecipe(title: String?, steps: [String?], image: UIImage?) {
        interactor.createRecipe(title: title, steps: steps, image: image) { [weak self] result in
            switch result {
            case .success:
                self?.view.showComplete()
            case let .failure(error):
                switch error {
                case .validationError:
                    self?.view.showValidationError()
                case let .creationError(error):
                    self?.view.showError(error)
                }
            }
        }
    }

    func close() {
        wireframe.close()
    }
}
```
</details>

## 答え

<details>
<summary>答えを見る</summary>

このPRのDiffを参照してください。

</details>

