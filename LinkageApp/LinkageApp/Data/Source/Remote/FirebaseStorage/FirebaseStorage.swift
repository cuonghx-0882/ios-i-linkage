//
//  FirebaseStoreage.swift
//  LinkageApp
//
//  Created by cuonghx on 5/8/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import FirebaseStorage

struct FirebaseStoreageService {
    
    // MARK: - Properties
    static let shared = FirebaseStoreageService()
    private var ref = Storage.storage().reference()
    
    // MARK: - Method
    func uploadImage(image: UIImage, path: String, completion: @escaping (URL?, Error?) -> Void) {
        if let data = UIImageJPEGRepresentation(image, 1) {
            ref.child(path).putData(data, metadata: nil) { (_, err) in
                if let err = err {
                    completion(nil, err)
                } else {
                    self.ref.child(path).downloadURL(completion: { (url, err) in
                        completion(url, err)
                    })
                }
            }
        } else {
            
        }
    }
}
