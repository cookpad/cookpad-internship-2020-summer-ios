//
//  InitialData.swift
//  MiniCookpad
//
//  Created by kensuke-hoshikawa on 2020/07/27.
//  Copyright © 2020 kensuke-hoshikawa. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

final class DummyData {
    static func insert() {
        let image = #imageLiteral(resourceName: "recipe_image")
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            fatalError()
        }

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let imagePath = "images/\(UUID()).jpg"
        let imageRef = Storage.storage().reference().child(imagePath)
        _ = imageRef.putData(imageData, metadata: metaData) { metadata, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }

            Self.insertRecipe(imagePath: imagePath)
        }
    }

    private static func insertRecipe(imagePath: String) {
        let collection = Firestore.firestore().collection("recipes")
        collection.addDocument(data: [
            "title": "おいしいアスパラの肉巻き",
            "steps": ["アスパラに豚バラを巻いて、フライパンに置き、塩胡椒します", "油は不要で、炒めます！", "焦げ目がついてきたら酒50mlをいれて蒸します", "2、3分経ったら、醤油とみりん、砂糖をいれます。", "水分がある程度飛んだら出来上がり！"],
            "createdAt": Date(),
            "userID": "123456778990",
            "imagePath": imagePath
        ]) { error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
}
