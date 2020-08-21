# 3.レシピ詳細画面をリファクタリング

できているとこまでコミットしておきましょう。

```shell
git commit -am "part1-test finished"
```

レシピ一覧のテストが完了できなかった人は part2 ブランチを checkout してください。

```
git checkout part2
```

### レシピ詳細画面をリファクタリング

レシピ詳細画面も、レシピ一覧画面と同様に RecipeDetailsViewController.swift に全てのコードが書かれています。

レシピ一覧画面のようにAPI処理をDataStoreに切り出したりContractやViewBuilderを作成して責務を分担してみましょう。  
空のファイルは用意されているため、ファイルを編集していってください。

尚、この画面ではテストか書かなくて良いです。

* やること
    * 遷移前画面から recipeID を受け取り、その ID をもとに Firestore からデータを取得し画面に表示
        * 取得失敗したらエラーダイアログを表示し、画面を閉じる
    * 画面を閉じるのも画面遷移と考え、Wireframe を経由する
    * データ取得ロジックは `RecipeDataStore` にメソッドを追加する

なお、データの取得は以下のコードを参考にしてください。

```swift
collection.document(recipeID).getDocument { snapshot, error in
    if let error = error {
        completion(.failure(error))
    } else {
        // 本来は `!` を使わずに、エラーハンドリングを行うべきだが割愛
        let recipe = try! snapshot!.data(as: FirestoreRecipe.self)!
        completion(.success(recipe))
    }
}
```

先ほどのドキュメントを参考にしつつ、まずはヒントを見ずにやってみてください。
わからず手が止まってしまう人は、以下のヒントを参照してください。Slack に質問を書いていただいても構いません。

(50分)

<details>
<summary>ヒント1</summary>

DataStore はこのようにします。  
`fetchAllRecipes` と違うのは、 recipeID を引数にとる必要がある点です。

```diff
// RecipeDataStore.swift
 protocol RecipeDataStoreProtocol {
     func fetchAllRecipes(completion: @escaping ((Result<[FirestoreRecipe], Error>) -> Void))
+    func fetchRecipe(recipeID: String, completion: @escaping ((Result<FirestoreRecipe, Error>) -> Void))
 }
```

```diff
// RecipeDataStore.swift
             }
         }
     +
}
+    func fetchRecipe(recipeID: String, completion: @escaping ((Result<FirestoreRecipe, Error>) -> Void)) {
+        collection.document(recipeID).getDocument { snapshot, error in
+            if let error = error {
+                completion(.failure(error))
+            } else {
+                let recipe = try! snapshot!.data(as: FirestoreRecipe.self)!
+                completion(.success(recipe))
+            }
+        }
+    }
 }
```

レシピ一覧の時と同じように、 ViewController で DataStore を使うように変えてみると DataStore がちゃんと実装できたかわかります。

</details>


<br>


<details>
<summary>ヒント2 </summary>

まず RecipeDetailsContract.swift を編集し、空の Protocol を定義しましょう。

```swift
protocol RecipeDetailsViewProtocol: AnyObject {
}

protocol RecipeDetailsPresenterProtocol: AnyObject {
}

protocol RecipeDetailsInteractorProtocol: AnyObject {
}

protocol RecipeDetailsWireframeProtocol: AnyObject {
}
```

そして、それぞれの Protocol と ViewBuilder を実装しましょう。

ViewBuilder では build 時に recipeID を引数で受け取ります。以下のように ViewBuilder 経由で RecipeDetails を生成できるようにしてみましょう。  

```swift
// ViewBuilder
import UIKit

struct RecipeDetailsViewBuilder {
    static func build(with recipeID: String) -> RecipeDetailsViewController {
        let viewController = RecipeDetailsViewController(recipeID: recipeID)
        let interactor = RecipeDetailsInteractor(recipeDataStore: RecipeDataStore())
        let wireframe = RecipeDetailsWireframe(viewController: viewController)
        let presenter = RecipeDetailsPresenter(view: viewController, interactor: interactor, wireframe: wireframe)
        viewController.inject(presenter: presenter)

        return viewController
    }
}
```

</details>

<br>

<details>
<summary>ヒント3</summary>

レシピ詳細画面で使われる Entity は `struct RecipeDetailsRecipe` として定義しましょう。  
それぞれの Protocol はこのようになります。この Protocol に則り実装してみましょう。

```swift
// RecipeDetailsContract
protocol RecipeDetailsViewProtocol: AnyObject {
    func showRecipe(_ recipe: RecipeDetailsRecipe)
    func showError(_ error: Error)
}

protocol RecipeDetailsPresenterProtocol: AnyObject {
    func refresh()
    func close()
}

protocol RecipeDetailsInteractorProtocol: AnyObject {
    func fetchRecipe(recipeID: String, completion: @escaping ((Result<RecipeDetailsRecipe, Error>) -> Void))
}

protocol RecipeDetailsWireframeProtocol: AnyObject {
    func close()
}
```

現状では ViewController が recipeID を持つようになっていますが、View は取得したデータを表示するだけが良いため、Presenter が recipeID を保持すると良いです。

```diff
// ViewBuilder
 struct RecipeDetailsViewBuilder {
     static func build(with recipeID: String) -> RecipeDetailsViewController {
-        let viewController = RecipeDetailsViewController(recipeID: recipeID)
+        let viewController = RecipeDetailsViewController()
         let interactor = RecipeDetailsInteractor(recipeDataStore: RecipeDataStore())
         let wireframe = RecipeDetailsWireframe(viewController: viewController)
-        let presenter = RecipeDetailsPresenter(view: viewController, interactor: interactor, wireframe: wireframe)
+        let presenter = RecipeDetailsPresenter(view: viewController, interactor: interactor, wireframe: wireframe, recipeID: recipeID)
         viewController.inject(presenter: presenter)
 
         return viewController

```

</details>

## 答え

<details>
<summary>答えを見る</summary>

このPRのDiffを参照してください。また、ヒントにも簡単な解説が書いてあるので、それも参照してください。



</details>
