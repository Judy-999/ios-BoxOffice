//
//  FireStoreManager.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/02.
//

import UIKit
import RxSwift
import FirebaseFirestore

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let database = Firestore.firestore()
    
    private init() { }
    
    func save(_ data: [String: Any],
              at collection: String,
              with id: String) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            self?.database.collection(collection).document(id).setData(data) { error in
                if error != nil {
                    emitter.onError(FirebaseError.save)
                }
                
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }

    func delete(with id: String, at collection: String) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            self?.database.collection(collection).document(id).delete { error in
                if error != nil {
                    emitter.onError(FirebaseError.delete)
                }
                
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }

    func fetch(at collection: String) -> Observable<[QueryDocumentSnapshot]> {
        return Observable.create { [weak self] emitter in
            self?.database.collection(collection).getDocuments { querySnapshot, error in
                if error != nil {
                    emitter.onError(FirebaseError.fetch)
                }
                
                if let documents = querySnapshot?.documents {
                    emitter.onNext(documents)
                }
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

