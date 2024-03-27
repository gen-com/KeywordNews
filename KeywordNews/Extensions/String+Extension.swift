//
//  String+Extension.swift
//  Keyword News Tests
//
//  Created by Byeongjo Koo on 2023/09/07.
//

import Foundation

extension String {
    /// 문자열을 날짜로 변환합니다.
    /// - Parameter format: 날짜 형식.
    /// - Returns: 변환한 날짜.
    func toDate(format: DateFormat) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = format.locale
        dateFormatter.dateFormat = format.rawValue
        guard let date = dateFormatter.date(from: self)
        else { throw CommonError.invalidConversion }
        return date
    }
}
