//
//  Namespace.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/02/27.
//

import UIKit

enum BoxOfficeImage {
    static let posterPlacehorder = UIImage(systemName: "nosign")
    static let photoPlacehorder = UIImage(systemName: "photo.on.rectangle.angled")
    static let calendar = UIImage(systemName: "calendar")
    static let checkMark = UIImage(systemName: "checkmark")
    static let share = UIImage(systemName: "square.and.arrow.up")
}

enum ReviewInfo {
    static let reviewLimitCount = 3
    
    enum Password {
        static let hiddenSign = "*"
        static let number = "0123456789"
        static let alphabet = "abcdefghijklmnopqrstuvwxyz"
        static let specialSymbol = "!@#$"
        static let numberRange = 6...20
    }
    
    enum Phrase {
        static let save = "저장"
        static let write = "리뷰 작성하기"
        static let more = "더보기"
        static let review = "리뷰"
        static let emptyReview = "작성된 리뷰가 없습니다."
        static let nicknamePlaceholder = "닉네임을 입력해주세요."
        static let passwordPlaceholder = "암호를 입력해주세요."
    }
    
    enum Alert {
        static let delete = "리뷰 삭제"
        static let saveFailure = "저장 실패"
        static let deleteFailure = "리뷰 삭제 실패"
        static let insufficient = "모든 항목을 작성해주세요."
        static let enterPassword = "암호를 입력해주세요."
        static let inconsistency = "암호가 일치하지 않습니다."
        static let confirm = "암호 확인"
        static let passwordRule = "암호는 6~20자리로 숫자, 영문 소문자, 특수문자(!, @, #, $)를 포함해야 합니다."
        static let ok = "확인"
        static let cancle = "취소"
    }
    
    enum Image {
        static let pencil = UIImage(systemName: "pencil")
        static let user = UIImage(systemName: "person.crop.circle")
        static let trash = UIImage(systemName: "trash")
        static let star = UIImage(systemName: "star.fill")
    }
    
    enum Rating {
        static let halfStarImage = UIImage(systemName: "star.leadinghalf.fill")
        static let emptyStarImage = UIImage(systemName: "star")
        static let fillStarImage = UIImage(systemName: "star.fill")
        static let halfValue: Float = 0.5
    }
}
