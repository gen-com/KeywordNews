//
//  NSManagedObject+Extension.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/26/24.
//

import CoreData

public extension NSManagedObject {
    convenience init(using context: NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "\(type(of: self).self)", in: context)
        else { throw CustomError.valueNotFound }
        self.init(entity: entity, insertInto: context)
    }
}
