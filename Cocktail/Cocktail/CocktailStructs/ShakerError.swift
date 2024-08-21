//
//  ShakerError.swift
//  Cocktail
//
//  Created by 강희성 on 2022/05/05.
//

import Foundation

enum ShakerError: Error {
case decoding(_ message: String = "디코딩 과정중에 오류가 발생했습니다")
case encoding(_ message: String = "인코딩 과정중에 오류가 발생했습니다")
case network(_ message: String = "인터넷 연결이 불안정합니다")
case firebase(_ message: String = "데이터를 불러오는중에 오류가 발생했습니다")
}
