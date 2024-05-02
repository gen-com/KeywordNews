//
//  Date+Extension.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 4/9/24.
//

import Foundation

extension Date {
    /// 일 수를 더한 새로운 날짜를 생성합니다.
    /// - Parameter days: 더할 일 수.
    /// - Returns: 새로운 날짜.
    func addingDays(_ days: Int) -> Date {
        self.addingTimeInterval(
            TimeInterval(Constant.hoursADay * Constant.minuteAnHour * Constant.secondsAMinute * days)
        )
    }
    
    /// 시간 상수 입니다.
    private enum Constant {
        static let hoursADay = 24
        static let minuteAnHour = 60
        static let secondsAMinute = 60
    }
}
