//
//  Constant.swift
//  fineDustCheck
//
//  Created by 서민영 on 2023/09/12.
//

import Foundation

class Constant {
    
    static let shared = Constant()
    var serviceKey = "dQvcyyxOzjnFNzzzTLJswHIA3jeUOFZgNeva%2BPp0i6kcdKC0Mp3lcO2yaP7%2Bzw4feTh1198PWuQ21jlO1sYyKQ%3D%3D"
    var kakaoUrl = "https://dapi.kakao.com/v2/local/geo/transcoord"
    var kakaoUrls = "https://dapi.kakao.com/v2/local/geo/coord2regioncode"
    var kakaoKey = "KakaoAK" + " " + "52dba01abfed03e730b4e3dc92c585d4"
    var stationUrl = "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getMsrstnList?"
    var dustUrl = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?"


    private init() { }
}
