# Firebase

https://firebase.google.com/products

- Google 傘下のサービス開発プラットフォームサービス
- アプリケーションに必要な様々なサービスを提供
  - DB、ファイルストレージ、認証、アナリティクス、クラッシュ計測
- クックパッドでは [Komerco](https://komer.co/) が特に活用している
  - モバイル/Web 双方で活用

## 今回使うもの

### Cloud Firestore

https://firebase.google.com/products/firestore

- スケーラブルな NoSQL データベース
- 今回はレシピ情報の保存をします
- オフラインDBなど、簡単に使えるのに多機能
- セキュリティルールには注意！
  - Firestore ではアプリから直接データベースを利用するため、見せてはいけない他者の情報などが見えてしまう
  - それを防ぐために、個人情報は自分自身しか参照出来ないようなセキュリティルールの設定が必要
  - [合計1億件以上の個人情報がFirebaseの脆弱性によって公開状態に \- GIGAZINE](https://gigazine.net/news/20180625-firebase-vulnerability-data-loss/)

自分のデータのみ読み書きできるようにするルールの例:

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, update, delete: if request.auth.uid == userId;
      allow create: if request.auth.uid != null;
    }
  }
}
```

> https://firebase.google.com/docs/firestore/security/rules-conditions?hl=ja

### Cloud Storage

https://firebase.google.com/products/storage

- 画像やサイズの大きなファイルなどをおいておくストレージ
- 今回はレシピ写真を保存しておきます
- Firestore と同様にルールには注意！

### Firebase Authentication

https://firebase.google.com/products/auth

- ユーザ登録やログインなどの認証機能
- 今回はユーザ登録機能を作成します
