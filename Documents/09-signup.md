# 認証機能

できているとこまでコミットしておきましょう。

```shell
git commit -am "part3-test finished"
```

part2 が完了できなかった人は part3 ブランチを checkout してください。

```
git checkout part4
```

Firebase Auth を使い、ユーザ認証を実装してみましょう。  
RecipeEditor と同じくこの画面も SignUpViewController として View だけは作成されています。

### 仕様

レシピ投稿ボタンをタップした時に、未ログイン状態だったらログイン画面を表示するようにしましょう。

- RecipeList 画面
  - 「レシピ投稿する」ボタンをタップした時
    - ユーザ作成済みだったら RecipeEditor を開く
    - ユーザ未作成だったら SignUp を開く
- SignUp 画面
  - メールアドレス、パスワードを入力して「新規登録」ボタンをタップ
  - 新規登録が成功したら、ユーザに「会員登録が成功しました」というのを伝え、SignUp 画面を閉じる
  - 新規登録が失敗したら、エラー内容をユーザに伝えてあげる

ログイン機能については今回は考慮せず新規会員登録のみ作成します。

メールアドレスが正しいかの検証は、Firebase 側で検証してくれるのでそこは Firebase に任せましょう。  
Firebase Auth のエラーハンドリングについては [Firebase iOS Auth エラーの処理](https://firebase.google.com/docs/auth/ios/errors?hl=ja) を参照ください。

### ログイン済かどうかの確認

```swift
import Firebase

let isLoggedIn = Auth.auth().currentUser?.uid != nil
```

### ユーザの作成

```swift
import Firebase

Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
    ...
}
```

## ヒント

発展課題のため、ノーヒントです。時間が有る限りどのようなコード、アーキテクチャで実現するか考えて実装してみてください。  
質問がある場合はお気軽に Slack へご連絡ください。

## 答え

<details>
<summary>答えを見る</summary>

[こちらの Diff](https://github.com/cookpad/cookpad-internship-2020-summer-ios/compare/part4..part4-completed) もしくは [part4完了時点のコード](https://github.com/cookpad/cookpad-internship-2020-summer-ios/tree/part4-completed)を参照してください。  
また、ヒントにも簡単な解説が書いてあるので、それも参照してください。


</details>
