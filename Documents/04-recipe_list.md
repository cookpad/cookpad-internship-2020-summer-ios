# 1.レシピ一覧画面をリファクタリング

* 機能
  * Firestore からデータを取得して TableView に表示
    * 取得失敗したらエラーダイアログを表示
  * レシピをタップしたらレシピ詳細画面へ遷移
  * PullToRefresh

MiniCookpad/Application/RecipeList/RecipeListViewController.swift が用意されていますが、データの取得や画面遷移が ViewController に記述されています。先ほど説明したアーキテクチャに沿ってリファクタリングしてみましょう。  

(50分)

* 早く終わった人は次のレシピ一覧のテストの章を進めてください。
* 何か質問があれば Slack に書いてください。(講義内容と関係のない、仕事の話やそれ以外の話でもお気軽に質問してOKです。)
* この講義を通して「模範解答」は用意していますが、解答や解説に疑問を抱いた場合や、自分の考えと違う場合は遠慮なく質問してください。

## レシピ一覧の表示

この画面では、Firestore からデータを取得し、そのデータを TableView に表示しています。
実装の流れとしては、データレイヤーを先に実装してからアプリケーションの実装をします。

まず `RecipeListViewController.swift` を読んでみて、どのような実装となっているか確認してみてください。

### ディレクトリ構成

先に空のファイルだけは用意してあります。用意されたファイルを編集していってください。

* MiniCookpad
  * Data
    * RecipeDataStore
      * RecipeDataStore.swift
      * FirestoreRecipe.swift
  * Application
    * RecipeList
      * RecipeListViewController.swift
      * RecipeTableViewCell.swift
      * RecipeListPresenter.swift
      * RecipeListContract.swift
      * RecipeListViewBuilder.swift
      * RecipeListInteractor.swift
      * RecipeListWireframe.swift
      * RecipeListRecipe.swift

### DataStore のレスポンス定義

Firestore から取得されたデータを表現する `FirestoreRecipe.swift` を作成します。

ViewController では直接 Firestore の取得結果を使ってしまっており、型情報も失われています。  
データ取得結果を struct で定義して、扱いやすくします。

```swift
// MiniCoopad/Data/RecipeDataStore/FirestoreRecipe.swift

import Foundation
// Firebase を Codable で利用できるライブラリ
import FirebaseFirestoreSwift

struct FirestoreRecipe: Codable, Equatable {
    /// recipes/:id の id
    @DocumentID var id: String?
    var title: String
    var imagePath: String
    var steps: [String]
    var createdAt = Date()
}
```

`@DocumentID` は、Swift5.1から導入された [Property Wrappers](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617) を使用しています。`@DocumentID` を付与すると、Firestore の documentID を Recipe の id として使用できます。[DocumentID.swiftの実装はこちら](https://github.com/firebase/firebase-ios-sdk/blob/53e91860e0081f912e95beb45fecb3bd72e5b03e/Firestore/Swift/Source/Codable/DocumentID.swift)

### DataStore の定義

現状 ViewController でデータの取得が行われており、View の責務を逸脱しています。そのため、データ取得処理を DataStore に分離します。

今回はレシピ情報を扱うため、 `RecipeDataStore` という名前にし、 Firestore からデータを取得できるようにします。

まず RecipeDataStoreProtocol を定義します。  
レシピ一覧画面では Firestore で全てのレシピを取得するため、 `fetchAllRecipes` という名前にします。 そして、その protocol を実装する RecipeDataStore を作成します。

ネットワーク接続となるため、非同期処理にする必要があります。  
ネットワーク処理の完了を伝えるため completion handler と Result を使用します。

```swift
// MiniCoopad/Data/RecipeDataStore/RecipeDataStore.swift

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
                    // 取得したデータを FirestoreRecipe に変換
                    .compactMap { try? $0.data(as: FirestoreRecipe.self)  }
                completion(.success(recipe))
            }
        }
    }
}
```

ここでは Firestore へのデータアクセス方法の解説はしませんが、詳しくは [Cloud Firestore でデータを取得する  \|  Firebase](https://firebase.google.com/docs/firestore/query-data/get-data) を参照してください。

### DataStore を使ってデータを取得してみる

DataStore ができたので、ここでひとまず ViewController のデータ取得部分を DataStore 経由で取得するよう書き換えます。

```diff
 // MiniCookpad/Application/RecipeList/RecipeListViewController.swift

 import Foundation
 import FirebaseFirestoreSwift

 class RecipeListViewController: UIViewController {
-    private var recipes: [QueryDocumentSnapshot] = []
+    private var recipes: [FirestoreRecipe] = []
     private let tableView = UITableView()
     private let refreshControl = UIRefreshControl()
     private let recipeCollection = Firestore.firestore().collection("recipes")
@@ -26,7 +26,7 @@ class RecipeListViewController: UIViewController {
         refresh()
     }

-    func showRecipes(_ recipes: [QueryDocumentSnapshot]) {
+    func showRecipes(_ recipes: [FirestoreRecipe]) {
         self.recipes = recipes
         refreshControl.endRefreshing()
         tableView.reloadData()
@@ -42,13 +42,13 @@ class RecipeListViewController: UIViewController {

     @objc private func refresh() {
         refreshControl.beginRefreshing()
-
-        recipeCollection.order(by: "createdAt", descending: true).getDocuments() { [weak self] querySnapshot, error in
-            if let error = error {
-                self?.showError(error)
-            } else {
-                let recipes = querySnapshot!.documents
+        let dataStore = RecipeDataStore()
+        dataStore.fetchAllRecipes { [weak self] result in
+            switch result {
+            case let .success(recipes):
                 self?.showRecipes(recipes)
+            case let .failure(error):
+                self?.showError(error)
             }
         }
     }
@@ -61,9 +61,10 @@ extension RecipeListViewController: UITableViewDelegate, UITableViewDataSource {

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
-        let recipeID = recipes[indexPath.row].documentID
-        let vc = RecipeDetailsViewController(recipeID: recipeID)
-        navigationController?.pushViewController(vc, animated: true)
+        if let recipeID = recipes[indexPath.row].id {
+            let vc = RecipeDetailsViewController(recipeID: recipeID)
+            navigationController?.pushViewController(vc, animated: true)
+        }
     }
```

Cell の方も、DataStoreのレシポンス型を使うように変更します

```diff
// MiniCookpad/Application/RecipeList/RecipeTableViewCell.swift

-    func configure(recipe: QueryDocumentSnapshot) {
+    func configure(recipe: FirestoreRecipe) {
         let placeholderImage = UIImage(systemName: "photo")
         // レシピ写真を Cloud Storage から取得して表示する
-        if let path = recipe.data()["imagePath"] as? String {
-            let ref = Storage.storage().reference(withPath: path)
-            thumbnailImageView.sd_setImage(with: ref, placeholderImage: placeholderImage)
-        } else {
-            thumbnailImageView.image = placeholderImage
-        }
-        recipeTitleLabel.text = recipe.data()["title"] as? String
-        descriptionLabel.text = (recipe.data()["steps"] as? [String])?.joined(separator: ", ")
+        let ref = Storage.storage().reference(withPath: recipe.imagePath)
+        thumbnailImageView.sd_setImage(with: ref, placeholderImage: placeholderImage)
+        recipeTitleLabel.text = recipe.title
+        descriptionLabel.text = recipe.steps.joined(separator: ", ")
     }
```

まず、これで ViewController からデータの取得処理を分離できました。`Command+R` でアプリを実行してみましょう。

### Application の雛形を作成する

データレイヤーはできたので、アプリケーションレイヤーを作っていきます。
まず、Contract にアプリケーションの Protocol を作成します。

参照を持ちたいため、 Protocol を実装できるのは AnyObject (class) にのみ縛ります。

```swift
// MiniCookpad/Application/RecipeList/RecipeListContract.swift

protocol RecipeListViewProtocol: AnyObject {
}

protocol RecipeListPresenterProtocol: AnyObject {
}

protocol RecipeListInteractorProtocol: AnyObject {
}

protocol RecipeListWireframeProtocol: AnyObject {
}
```

そして次に、Protocol を実装した空の class を作成します。
`MiniCookpad/Application/RecipeList/` に空のファイルは置いてあるため、そのファイルを編集していってください。

それぞれの要素は、Protocol での依存になります。後ほどテストを記述しますが、 Protocol 依存にしておくとテストを書く際に Mock に差し替えることができるようになります。

Interactor は DataStore を使用するため、 init で recipeDataStore を引数にとります。

```swift
// MiniCookpad/Application/RecipeList/RecipeListInteractor.swift
class RecipeListInteractor: RecipeListInteractorProtocol {
    private let recipeDataStore: RecipeDataStoreProtocol
    init(recipeDataStore: RecipeDataStoreProtocol) {
        self.recipeDataStore = recipeDataStore
    }
}
```

Presenter は View, Interactor, Wireframe と依存があるため、init で3つの引数を受け取ります。
View は循環参照を防ぐため、 `weak` にします。

```swift
// MiniCookpad/Application/RecipeList/RecipeListPresenter.swift
class RecipeListPresenter: RecipeListPresenterProtocol {
    private weak var view: RecipeListViewProtocol!
    private let interactor: RecipeListInteractorProtocol
    private let wireframe: RecipeListWireframeProtocol
    init(view: RecipeListViewProtocol, interactor: RecipeListInteractorProtocol, wireframe: RecipeListWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}
```

Wireframe は画面遷移をする都合、viewController を保持します。View は循環参照を防ぐため、 `weak` にします。

```swift
// MiniCookpad/Application/RecipeList/RecipeListWireframe.swift
import UIKit

class RecipeListWireframe: RecipeListWireframeProtocol {
    private weak var viewController: UIViewController!
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
```

ViewController だけはすでに実装があるため、`RecipeListViewProtocol` を実装するよう編集します。

View は presenter にイベントを伝えるため、 presenter のインスタンスを保持します。
Presenter より先に View を init する関係で、 inject メソッドを用意しそこで presenter を渡しています。

```diff
// MiniCookpad/Application/RecipeList/RecipeListViewController.swift
-class RecipeListViewController: UIViewController {
+class RecipeListViewController: UIViewController, RecipeListViewProtocol {
     private var recipes: [Recipe] = []
     private let tableView = UITableView()
     private let refreshControl = UIRefreshControl()
     private let recipeCollection = Firestore.firestore().collection("recipes")
+    private var presenter: RecipeListPresenterProtocol!

+    func inject(presenter: RecipeListPresenterProtocol) {
+        self.presenter = presenter
+    }
```

これで画面の雛形が作成できました。

### ViewBuilder 経由で画面をビルド

ViewBuilder 経由で RecipeList を生成するようにします。

ViewBuilder ではそれぞれのインスタンスを生成し、DI します。
それぞれのレイヤーは Protocol 依存となっていましたが、ここで依存を解決します。

この画面では `build()` に引数は不要ですが、画面構築時に何か情報が必要な時は `build(recipeID: String)` のように、引数で受けます。

```swift
// MiniCookpad/Application/RecipeList/RecipeListViewBuilder.swift
struct RecipeListViewBuilder {
    static func build() -> RecipeListViewController {
        let viewController = RecipeListViewController()
        let recipeDataStore = RecipeDataStore()
        let interactor = RecipeListInteractor(recipeDataStore: recipeDataStore)
        let wireframe = RecipeListWireframe(viewController: viewController)
        let presenter = RecipeListPresenter(view: viewController, interactor: interactor, wireframe: wireframe)
        viewController.inject(presenter: presenter)

        return viewController
    }
}
```

そして最後に、RecipeListViewController を ViewBuilder 経由で作成するよう変更します。

```diff
// MiniCookpad/SceneDelegate.swift

@@ -16,7 +16,7 @@ class SceneDelegate: UIResponder, UIWindowSceneDelegate {
         self.window = window
         window.makeKeyAndVisible()

-        let recipeListViewController = RecipeListViewController()
+        let recipeListViewController = RecipeListViewBuilder.build()
         let rootNavigationViewController = UINavigationController(rootViewController: recipeListViewController)
         window.rootViewController = rootNavigationViewController
     }
```

これで、アーキテクチャの雛形の作成が終わりです。
正常に画面が表示できるか、シュミレーターで実行してみましょう。

## Interactor 経由でデータを取得する

DataStore の作成が完了し、Application も一通りファイル作成できました。
先ほどはひとまず ViewController で DataStore を使っていましたが、 Interactor 経由でデータを取得できるようにします。

### Entity を定義

Intaractor では、データの取得結果をEntityである `RecipeListRecipe` に変換します。

`FirestoreRecipe` はこの画面で使用しないフィールドを持っていたり、`@DocumentID` など画面が知る必要のない情報を持っています。  
そのため、 `FirestoreRecipe` から必要なフィールドだけ抽出した `RecipeListRecipe` を用意します。

あとでテストを書く際に必要になるため、 `Equatable` に適合しておきます。

```swift
// MiniCookpad/Application/RecipeList/RecipeListRecipe.swift

struct RecipeListRecipe: Equatable {
    var id: String
    var title: String
    var imagePath: String
    var steps: [String]
}
```

### Interactor を実装

ビジネスロジックを担う、Interactor を作成します。

Interactor では、 DataStore を経由してデータを取得し、取得結果を `RecipeListRecipe` へ変換します。

まずは protocol の定義を行います。DataStore と同様、コールバックで結果を返却します。

```diff
// RecipeListContract.swift
 protocol RecipeListInteractorProtocol: AnyObject {
+    func fetchAllRecipes(completion: @escaping ((Result<[RecipeListRecipe], Error>) -> Void))
 }
```

この protocol を満たす Interactor を実装します。DataStore にデータの取得をお願いし、結果を `[FirestoreRecipe]` から `[RecipeListRecipe]` に変換しています。

```diff
// MiniCookpad/Application/RecipeList/RecipeListInteractor.swift
     init(recipeDataStore: RecipeDataStoreProtocol) {
         self.recipeDataStore = recipeDataStore
     }
+
+    func fetchAllRecipes(completion: @escaping ((Result<[RecipeListRecipe], Error>) -> Void)) {
+        recipeDataStore.fetchAllRecipes { result in
+            switch result {
+            case let .success(firestoreRecipes):
+                let recipes: [RecipeListRecipe] = firestoreRecipes.compactMap { firestoreRecipe in
+                    if let recipeID = firestoreRecipe.id {
+                        return RecipeListRecipe(id: recipeID, title: firestoreRecipe.title, imagePath: firestoreRecipe.imagePath, steps: firestoreRecipe.steps)
+                    } else {
+                        return nil
+                    }
+                }
+                completion(.success(recipes))
+            case let .failure(error):
+                completion(.failure(error))
+            }
+        }
+    }
 }
```

### Presenter

Presenter の protocol を定義します。
View からの要求に答え、Interactor にデータ取得処理を橋渡しします。これで Interactor が View に関心を持たなくて済むようになります。  
Presenter は、取得結果によって View がどういう振る舞いをするべきか、という判断に集中できるようになります。

```diff
// RecipeListContract.swift
 protocol RecipeListPresenterProtocol: AnyObject {
+    func refresh()
 }
```

この protocol を満たす Presenter を実装します。
`refresh()` では、 Interactor にデータの取得をお願いし、その結果を view に通知します。view はまだ実装できていないので、TODOにしておきます。

```diff
// MiniCookpad/Application/RecipeList/RecipeListPresenter.swift
         self.interactor = interactor
         self.wireframe = wireframe
     }
+
+    func refresh() {
+        interactor.fetchAllRecipes { [weak self] result in
+            switch result {
+            case let .success(recipes):
+                // TODO: view にレシピ取得完了を伝える
+                break
+            case let .failure(error):
+                // TODO: view にエラーを伝える
+                break
+            }
+        }
+    }
 }
```

### View

View の Protocol を定義します。
今回はデータ取得完了後に画面を更新するメソッドを定義します。

```diff
// RecipeListContract.swift
 protocol RecipeListViewProtocol: AnyObject {
+    func showRecipes(_ recipes: [RecipeListRecipe])
+    func showError(_ error: Error)
 }
```

この Protocol を満たす View  を実装します。
View の役割は画面の表示とユーザインタラクションをPresenterに伝えることなので、その責務に徹します。

先ほど DataStore を直接使うように変更したところを、`presenter.refresh()` に変更します。また、`FirestoreRecipe` を使っていましたが Entity である `RecipeListRecipe` に変更します。

```diff
// MiniCookpad/Application/RecipeList/RecipeListViewController.swift
 import FirebaseFirestoreSwift
 
 class RecipeListViewController: UIViewController, RecipeListViewProtocol {
-    private var recipes: [FirestoreRecipe] = []
+    private var recipes: [RecipeListRecipe] = []
     private let tableView = UITableView()
     private let refreshControl = UIRefreshControl()
     private let recipeCollection = Firestore.firestore().collection("recipes")
@@ -31,7 +31,7 @@ class RecipeListViewController: UIViewController, RecipeListViewProtocol {
         refresh()
     }
     
-    func showRecipes(_ recipes: [FirestoreRecipe]) {
+    func showRecipes(_ recipes: [RecipeListRecipe]) {
         self.recipes = recipes
         refreshControl.endRefreshing()
         tableView.reloadData()
@@ -47,16 +47,7 @@ class RecipeListViewController: UIViewController, RecipeListViewProtocol {
     
     @objc private func refresh() {
         refreshControl.beginRefreshing()
-        
-        let dataStore = RecipeDataStore()
-        dataStore.fetchAllRecipes { [weak self] result in
-            switch result {
-            case let .success(recipes):
-                self?.showRecipes(recipes)
-            case let .failure(error):
-                self?.showError(error)
-            }
-        }
+        presenter.refresh()
     }
 }
 
@@ -67,10 +58,9 @@ extension RecipeListViewController: UITableViewDelegate, UITableViewDataSource {
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
-        if let recipeID = recipes[indexPath.row].id {
-            let vc = RecipeDetailsViewController(recipeID: recipeID)
-            navigationController?.pushViewController(vc, animated: true)
-        }
+        let recipeID = recipes[indexPath.row].id
+        let vc = RecipeDetailsViewController(recipeID: recipeID)
+        navigationController?.pushViewController(vc, animated: true)
     }
```

RecipeTableViewCell でも `FirestoreRecipe` を使っているので `RecipeListRecipe` を使うよう変更します。

```diff
// MiniCookpad/Application/RecipeList/RecipeTableViewCell.swift
-    func configure(recipe: FirestoreRecipe) {
+    func configure(recipe: RecipeListRecipe) {
```

### Presenter

View の実装ができたので、先ほど TODO としていた箇所を修正します。

```diff
// MiniCookpad/Application/RecipeList/RecipeListPresenter.swift
         interactor.fetchAllRecipes { [weak self] result in
             switch result {
             case let .success(recipes):
-                // TODO: view にレシピ取得完了を伝える
-                break
+                self?.view.showRecipes(recipes)
             case let .failure(error):
-                // TODO: view にエラーを伝える
-                break
+                self?.view.showError(error)
             }
         }
```

これでアーキテクチャに則りデータ取得の流れをリファクタリングできました。
シュミレータで動くか試してみましょう。

## 画面遷移を実装する

データの取得はリファクタリングできましたが、今度は画面遷移を Wireframe 経由でやってみましょう。

### Wireframe の実装

レシピ詳細画面へ遷移する protocol を定義します。レシピ詳細画面を開くには recipeID が必要なので、引数で渡すようにします。
Wireframe があることで、Presenter で画面遷移のテストが書けたり、画面遷移先が一覧で可視化できます。

```diff
// RecipeListContract.swift
 protocol RecipeListWireframeProtocol: AnyObject {
+    func openRecipeDetails(recipeID: String)
 }
```

Wireframe は画面遷移が必要なため、 ViewController のインスタンスを保持します。

```diff
// MiniCookpad/Application/RecipeList/RecipeListWireframe.swift

     init(viewController: UIViewController) {
         self.viewController = viewController
     }
+
+    func openRecipeDetails(recipeID: String) {
+        let vc = RecipeDetailsViewController(recipeID: recipeID)
+        viewController.navigationController?.pushViewController(vc, animated: true)
+    }
 }
```

### Presenter から Wireframe を呼ぶ

Presenter の protocol にレシピ詳細画面を開くメソッドを追加します。

```diff
// RecipeListContract.swift

protocol RecipeListPresenterProtocol: AnyObject {
    func refresh()
+   func openRecipeDetails(recipeID: String)
}
```

Presenter で、 protocol の実装をします。


```diff
// MiniCookpad/Application/RecipeList/RecipeListPresenter.swift
             }
         }
     }
+
+    func openRecipeDetails(recipeID: String) {
+        wireframe.openRecipeDetails(recipeID: recipeID)
+    }
 }
```

### View から presenter 経由で画面遷移する

最後に、 ViewController から直接レシピ詳細画面を開いている箇所を Presenter 経由に変更します。

```diff
// MiniCookpad/Application/RecipeList/RecipeListViewController.swift
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         let recipeID = recipes[indexPath.row].id
-        let vc = RecipeDetailsViewController(recipeID: recipeID)
-        navigationController?.pushViewController(vc, animated: true)
+        presenter.openRecipeDetails(recipeID: recipeID)
     }
```

以上で、アーキテクチャに則り画面遷移ができるようになりました。
シミュレータを起動してみましょう。

## ファイルが分割されどうなったか？

- 全体の処理が分割され、1ファイルごとの見通しがよくなった
    - ファイル数は増えた
- ViewController は画面の表示、ユーザインタラクションに徹することができるようになった
- 将来 Firestore を外すことを考えたとき、DataStore を入れ替えるだけでよくなった
- protocol 依存となったため、テストが書きやすくなった
  - 次の章でテストを書きます

(ここで休憩)
