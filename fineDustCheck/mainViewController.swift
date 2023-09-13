//
//  ViewController.swift
//  fineDustCheck
//
//  Created by 서민영 on 2023/09/12.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Then

class mainViewcontroller: UIViewController, CLLocationManagerDelegate {
    
    struct userLocation {
        var latitude: Double!
        var longitude: Double!
        var currentLatitude: Double!
        var currentLongitude: Double!
    }
    
    lazy var locationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        $0.distanceFilter = kCLHeadingFilterNone
        $0.requestWhenInUseAuthorization()
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dataTimeLabel: UILabel!
    @IBOutlet weak var PMLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var PMGradeImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getLocationUsagePermission()
        // 델리게이트 설정
        locationManager.delegate = self
        // 거리 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 사용자에게 허용 받기 alert 띄우기
        locationManager.requestWhenInUseAuthorization()
        
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        if CLLocationManager.locationServicesEnabled() {
        
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
            print(locationManager.location?.coordinate)
        } else {
            print("위치 서비스 Off 상태")
        }
        
     
        
    }
    
    // 현재장소 정보
    func currentLocation(url: String, longitude: Double, latitude: Double) {
        var result = userLocation()
        let headers:HTTPHeaders = ["Authorization" : Constant.shared.kakaoKey]
        let parameters: Parameters = ["x" : longitude, "y" : latitude, "output_coord" : "TM"]
        let alamo = AF.request(Constant.shared.kakaoUrls, method: .get,parameters: parameters, encoding: URLEncoding.queryString ,headers: headers)
        alamo.responseJSON() { response in
            debugPrint(response)
            switch response.result {
             
            case .success(let value):
                let json = JSON(value)
                let documents = json["documents"].arrayValue
                
                result.currentLongitude = documents[0]["x"].double
                result.currentLatitude = documents[0]["y"].double
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    

    // TM좌표로 변환
    func TM(url: String, longitude: Double, latitude: Double, handler: @escaping(userLocation) -> Void) {
        var result = userLocation()
        let headers:HTTPHeaders = ["Authorization" : Constant.shared.kakaoKey]
        let parameters: Parameters = ["x" : longitude, "y" : latitude, "output_coord" : "TM"]
        
        let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.queryString ,headers: headers)
        alamo.responseJSON() { response in
            debugPrint(response)
            switch response.result {
             
            case .success(let value):
                let json = JSON(value)
                let documents = json["documents"].arrayValue
                result.longitude = documents[0]["x"].double
                result.latitude = documents[0]["y"].double
                handler(result)
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    // 측정 장소 가져오기
    func getNearbyMsrstn(url: String, tmX: Double, tmY: Double, handler: @escaping(String) -> Void) {
        let parameters: Parameters = [
            "tmX" : tmX,
            "tmY" : tmY,
            "returnType" : "json"
        ]

        let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.default)
        alamo.responseJSON() { response in
            debugPrint(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let stationName = json["response"]["body"]["items"][0]["stationName"].string!
                var stations = json["response"]["body"]["items"].arrayValue
                var stationNameData = stations.last?["stationName"].string!
           
                print("장소이름\(stationNameData)")
                LocationInfo.shared.stationName = stationNameData
                handler(stationName)
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    //미세먼지 농도
    func getfinedust(url: String, stationName: String, handler: @escaping(String, String, String) -> Void) {
        let parameters: Parameters = [
            "stationName" : stationName,
            "dataTerm" : "DAILY",
            "returnType" : "json"
        ]
        
     
        let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.default)
        alamo.responseJSON() { response in
            debugPrint(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let pm10Value = json["response"]["body"]["items"][0]["pm10Value"].string!
                let pm10GradeValue = json["response"]["body"]["items"][0]["pm10Grade"].string!
                let dataTime = json["response"]["body"]["items"][0]["dataTime"].string!
                
                LocationInfo.shared.pmGradeValue = pm10GradeValue
                LocationInfo.shared.dataTime = dataTime
                LocationInfo.shared.pmValue = pm10Value
                handler(pm10Value,pm10GradeValue, dataTime)
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    func getLocationUsagePermission() {
          //location4
          self.locationManager.requestWhenInUseAuthorization()

      }


    //위치 정보
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            self.locationManager.startUpdatingLocation() // 중요!
            let coord = self.locationManager.location?.coordinate
            LocationInfo.shared.latitude = coord?.latitude
            LocationInfo.shared.longitude = coord?.longitude

            self.TM(url: Constant.shared.kakaoUrl, longitude: coord!.longitude, latitude: coord!.latitude) { userLocation in
                self.getNearbyMsrstn(url: Constant.shared.stationUrl, tmX: userLocation.longitude, tmY: userLocation.latitude ) { station in
                    DispatchQueue.main.async {
                        print(station)
                        self.stationLabel.text = "측정 장소 : \(station)"
                    }
                    self.getfinedust(url: Constant.shared.dustUrl, stationName: station) { pm,pmGrade,time in
                        DispatchQueue.main.async {
                            switch pmGrade {
                            case "1" :
                                self.PMGradeImage.image = UIImage(named: "smile.png")
                            case "2" :
                                self.PMGradeImage.image = UIImage(named: "normal.png")
                            case "3" :
                                self.PMGradeImage.image = UIImage(named: "bad.png")
                            case "4" :
                                self.PMGradeImage.image = UIImage(named: "evil.png")
                            default :
                                print("Unkown")
                            }
                            self.dataTimeLabel.text = "측정 시간 : \(time)"
                            self.PMLabel.text = "\(pm)㎍/㎥"
                        }
                    }
                }
            }
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            getLocationUsagePermission()
        default:
            print("GPS: Default")
        }
    }
    
    
    
}

