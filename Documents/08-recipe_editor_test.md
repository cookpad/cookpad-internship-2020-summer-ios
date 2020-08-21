## テストを書いてみる

できているとこまでコミットしておきましょう。

```shell
git commit -am "part3 finished"
```

part2 が完了できなかった人は part3 ブランチを checkout してください。

```
git checkout part3-test
```

以下のケースの Interactor のテストを書いてみましょう

1. title, steps, image のデータが正しいかつ、2つのAPIを待ち合わせして両方成功したら success が返るか
2. 画像の登録が失敗したら failure が返るか
4. title だけが nil の場合、failure が返るか
5. steps の一部がから文字列の時に failure が返るか `["step1", "", "step2"]`
6. steps に絵文字📱が含まれていた場合、 failure が返るか `["step1", "📱"]`


<details>
<summary>ヒント1</summary>

レシピ一覧のテストの時と同じく、まず Mock を作りましょう。  
今回は Interactor のテストを書くので、依存のある `ImageDataStore` と `RecipeDataStore` の Mock を作成します。

```swift
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
```
</details>

<br>

<details>
<summary>ヒント2</summary>

レシピの作成が成功するときのテストは以下のようになります。  
レシピ一覧のテストの時と同じく、Mock に期待する返り値を代入しておいて、その Mock を使い Interactor を生成します。

{} で囲まれている箇所は自分で書いてみましょう。

```swift
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
        imageDataStore.createImageResult = {画像の作成が成功したときの Result を代入}
        recipeDataStore.createRecipeResult = {レシピの作成が成功したときの Result を代入}
        let interactor = {Mock を利用した Interactor を作成}

        let image = #imageLiteral(resourceName: "recipe_image")
        // 正しい入力項目で createRecipe を実行
        interactor.createRecipe(title: "title", steps: ["steps"], image: image) { result in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure:
                XCTFail()
            }
        }
    }
}
```
</details>

<br>

<details>
<summary>ヒント3</summary>

ヒント2の {} で囲まれている箇所は以下のようになります。

```swift
        imageDataStore.createImageResult = .success(imagePath)
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
```

成功するテストは書けたので、それを応用し画像・レシピの登録失敗ケースや入力に問題がある場合のテストも記述してみましょう。

</details>

<br>

<details>
<summary>ヒント4</summary>

レシピの作成が失敗したときのテストは、 createImageResult に失敗を渡すだけです。  
{} の中身を埋めてみましょう。

```swift
    func testCreateRecipe_CreateImageFailure() {
        let error = NSError(domain: "", code: 11111111, userInfo: nil)
        imageDataStore.createImageResult = {失敗のResultを代入}
        recipeDataStore.createRecipeResult = .success(())
        let interactor = RecipeEditorInteractor(imageDataStore: imageDataStore, recipeDataStore: recipeDataStore)
        let image = #imageLiteral(resourceName: "recipe_image")
        interactor.createRecipe(title: "title", steps: ["steps"], image: image) { result in
            switch result {
            case .success:
                {XCTAssert(true) or XCTFail()}
            case let .failure(resultError):
                switch resultError {
                case .creationError:
                    {XCTAssert(true) or XCTFail()}
                case .validationError:
                    {XCTAssert(true) or XCTFail()}
                }
            }
        }
    }
```

</details>

## 答え

<details>
<summary>答えを見る</summary>

このPRのDiffを参照してください。
</details>
