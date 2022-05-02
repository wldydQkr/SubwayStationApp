//
//  StationResponseModel.swift
//  Subway
//
//  Created by 박지용 on 2022/05/01.
//

import Foundation

struct StationResponseModel: Decodable {
    var stations: [Station] { searchInfo.row } // private와 바로 리턴해주는걸 사용하면 코드는 복잡해 질 수 있으나 사용할 때는 편하다.
    
    private let searchInfo: SearchInfoBySubwayNameServiceModel
    
    enum CodingKeys: String, CodingKey {
        case searchInfo = "SearchInfoBySubwayNameService"
    }
    
    struct SearchInfoBySubwayNameServiceModel: Decodable {
        var row: [Station] = []
    }
}

struct Station: Decodable {
    let stationName: String
    let lineNumber: String
    
    enum CodingKeys: String, CodingKey {
        case stationName = "STATION_NM"
        case lineNumber = "LINE_NUM"
    }
}
