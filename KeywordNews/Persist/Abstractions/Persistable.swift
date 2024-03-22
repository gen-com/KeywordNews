//
//  Persistable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/23/24.
//

import CoreData

/// 디스크에 저장가능한 유형을 정의합니다.
protocol Persistable {
    var container: NSPersistentContainer { get }
}
