# 2.レシピ一覧画面のテストを書いてみる

ひとまず現状できているとこまでコミットしておきましょう。

```shell
git commit -am "part1 finished"
```

part1 が完了できなかった人は part1-test ブランチを checkout してください。

```
git checkout part1-test
```

## テストを書く

Presenter のテストを書いてみましょう。refresh が正しく動作しているかの確認をします。

- presenter の refresh が成功したら、`view.showRecipes(_ recipe: RecipeListRecipe)` が実行されること
- presenter の refresh が失敗したら、`view.showError(_ error: Error)` が実行されること

この2つを検証します。

もしリファクタリング前の ViewController に全てが記述されていた状態だと、データ取得完了後のテストを書きたい場合は、本当に Firestore にアクセスしなければなりません。テストをする際にネットワーク接続などがあるとテスト自体が不安定になってしまいます。

ですが、 Protocol 依存にしたことで依存先を Mock に差し替えることが可能になり、個別の機能ごとのテストが書きやすくなりました。  
Interactor や View を Mock して、Presenter が正しく動いているかを検証してみましょう。

(20分)

### Mock の View, Interactor, Wireframe を作成する

Presenter は init で ViewController, Interactor, Wireframe を受け取ります。
ですがそれは Protocol に対する依存なので、先に述べたとおりそれぞれの実装は Mock に差し替えることで簡単に Presenter のテストをすることが可能です。

MiniCookpadTestsを右クリックし、`RecipeListPresenterTests.swift` ファイルを作成して、以下のように編集してください。

```swift
// MiniCookpadTests/RecipeListPresenterTests.swift

import XCTest
@testable import MiniCookpad

class MockRecipeListViewController: RecipeListViewProtocol {
    var recipes: [RecipeListRecipe]?
    func showRecipes(_ recipes: [RecipeListRecipe]) {
        self.recipes = recipes
    }
    var error: Error?
    func showError(_ error: Error) {
        self.error = error
    }
}

class MockRecipeListInteractor: RecipeListInteractorProtocol {
    var fetchAllRecipesResult: (Result<[RecipeListRecipe], Error>)!
    func fetchAllRecipes(completion: @escaping ((Result<[RecipeListRecipe], Error>) -> Void)) {
        completion(fetchAllRecipesResult)
    }
}

class MockRecipeListWireframe: RecipeListWireframeProtocol {
    func openRecipeDetails(recipeID: String) { }
}
```

- MockRecipeListViewController
  - RecipeListViewProtocol を実装
  - showRecipe, showError を検証できるように変数で recipes, error を保持しています
- MockRecipeListInteractor
  - RecipeListInteractorProtocol を実装
  - fetchAllRecipes の結果を差し込めるようにしています
- MockRecipeListWireframe
  - RecipeListWireframeProtocol を実装
  - 今回はテストとは関係ないので、 Protocol を実装しただけになっています

### refresh 成功のテスト

Mock の作成はできたので、`refresh()` が成功したケースのテストを書いていきます。
`MockRecipeListWireframe` の下に続けて以下を書いてください。

RecipeListPresenter を init するタイミングで Mock を渡しています。
これで、 Presenter は本物を使いつつ他は Mock に差し替えることができます。

interactor.fetchAllRecipesResult で結果を先に渡すことで、成功パターンのテストができます。

```swift
class RecipeListPresenterTests: XCTestCase {
    var view: MockRecipeListViewController!
    var interactor: MockRecipeListInteractor!
    var wireframe: MockRecipeListWireframe!

    // テストのたびに Mock の状態をリセットする
    override func setUp() {
        super.setUp()
        view = MockRecipeListViewController()
        interactor = MockRecipeListInteractor()
        wireframe = MockRecipeListWireframe()
    }

    func testRefreshSucceeded() {
        let recipes = [RecipeListRecipe(id: "1", title: "title", imagePath: "dummy_path", steps: [])]
        interactor.fetchAllRecipesResult = .success(recipes)
        let presenter = RecipeListPresenter(view: view, interactor: interactor, wireframe: wireframe)

        presenter.refresh()
        XCTAssertEqual(view.recipes, recipes)
    }
}
```

`Command + U` でテストを実行してみてください。
`presenter.refresh()` を実行すると、`view.recipes` にレシピデータが入っていることを確認できます。

### fetchAllRecipes 失敗のテスト

次に失敗のテストを書きます。
成功した際のテストと違うのは、`interactor.fetchAllRecipesResult` でエラーを渡しているのと、XCTAssertEqualでerrorの検証をしている点です。

```swift
    func testFetchRecipesFailure() {
        let error = NSError(domain: "", code: 11111111, userInfo: nil)
        interactor.fetchAllRecipesResult = .failure(error)
        let presenter = RecipeListPresenter(view: view, interactor: interactor, wireframe: wireframe)

        presenter.refresh()
        XCTAssertEqual((view.error! as NSError), error)
    }
```

エラーの際は `view.error` が実行されていることが確認できました。

## おわり

大きなレシピ一覧画面をリファクタリングし、Protocol 同士の依存となったためテストも書きやすくなりました。
これで今後レシピ一覧画面に機能が足されても改善していけそうですね。

(早く終わった人は 06-recipe_details.md へ)
