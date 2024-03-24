//
//  UnknownError.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 11/27/23.
//

/// 일반적으로 발생할 수 있는 오류를 정의합니다.
enum CustomError: PresentableError {
    /// 알 수 없는 오류.
    case unknown
    /// 유효하지 않은 변환.
    case invalidConversion
    /// 존재하지 않는 값.
    case valueNotFound
    /// 인코딩 실패.
    case failToEncode
    /// 디코딩 실패.
    case failToDecode
    
    var title: String {
        switch self {
        case .unknown: 
            return "알 수 없는 오류"
        case .invalidConversion: 
            return "유효하지 않은 변환"
        case .valueNotFound: 
            return "찾을 수 없는 값"
        case .failToEncode: 
            return "암호화 실패"
        case .failToDecode: 
            return "해독 실해"
        }
    }
    
    var description: String {
        switch self {
        case .unknown: 
            return "알 수 없는 오류가 발생했습니다."
        case .invalidConversion: 
            return "유효하지 않은 값으로 변환을 시도했습니다."
        case .valueNotFound: 
            return "값이 존재하지 않습니다."
        case .failToEncode: 
            return "값을 암호화하는데 실패했습니다."
        case .failToDecode: 
            return "값을 해독하는데 실패했습니다."
        }
    }
}
