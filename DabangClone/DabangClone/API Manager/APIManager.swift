//
//  APIManager.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/04/24.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import RxSwift

enum SaleInfoError: Error {
  case badGatewa
}

enum LoginWays {
    case local
    case apple
    case kakao
    case facebook
}

enum Key {
    static let keyChain = "keyChain"
}

final class APIManager {
    
    // MARK: - Properties
    static let shared = APIManager()
    private var request: DataRequest? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    private let keyChain = KeychainSwift(keyPrefix: "DabangCloneUser_")
    var userPk = 0
    private let networkAccessManager = NetworkReachabilityManager(host: "http://dabang-loadbalancer-779366673.ap-northeast-2.elb.amazonaws.com")
    private let baseURL = "http://dabang-loadbalancer-779366673.ap-northeast-2.elb.amazonaws.com"
    
    var loginWay: LoginWays?
    
    private init() { monitorNetworkAccessStatus() }
    
    
    // MARK: - [ Monitoring Celluar Network Access Status ]
    private func monitorNetworkAccessStatus() {
        networkAccessManager?.startListening(onQueue: .init(label: "networkQueue"), onUpdatePerforming: { (status) in
            print("Network Status has been changed: \(status)")
        })
    }
    
    
    // MARK: - [ Manage JWT ]
    func getAccessTokenFromKeyChain() -> String {
//        let accessToken = keyChain.get(Key.keyChain) ?? ""
        let tempToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImFkbWluIiwiZXhwIjoxNTkxOTU2MTY0LCJlbWFpbCI6ImFkbWluQGdvb2dsZS5jb20ifQ.JsrV4hCOQl857pVCxcaCup1alS5yE_ftz7Yw2yXD1CA"
        return tempToken
    }
    
    func setAccessTokenIntoKeyChain(token: String, key: String) -> Bool {
        return keyChain.set(token, forKey: key, withAccess: .accessibleWhenUnlocked)
    }
    
    func checkJWTExpiration() {
        let jwt = getAccessTokenFromKeyChain()
        var payloadString = jwt.components(separatedBy: ".")[1]
        while payloadString.count % 4 != 0 {
            payloadString += "="
        }

        let payloadData = Data(base64Encoded: payloadString, options: .ignoreUnknownCharacters)!

        guard let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String:Any] else { return }
        let exp = json["exp"] as! Int
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        if expDate <= Date() {
//            refreshJWT()
        }
    }
    
    func logout() -> Bool {
      return keyChain.clear()
    }
    
    // MARK: - [ API CRUD ]
    // MARK: - GET
    
    //GET: 유저 정보
    func getUserProfile(userPK: Int? = nil, completion: @escaping (Result<User, Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        self.request = AF.request( baseURL + "/members/\(String(describing: userPK))/", headers: header)
        self.request?.responseDecodable(of: User.self) { (response) in
                switch response.result {
                case .success(let user):
                    print("success")
                    completion(.success(user))
                case .failure(let error):
                    print("fail222")
                    completion(.failure(error))
                }
        }
    }
    
    //GET: 방 전체 리스트
    func getEntireRoomData(completion: @escaping (Result<[DabangElement], Error>) -> Void) {
        AF.request( baseURL + "/posts/list/")
          .responseDecodable(of: [DabangElement].self) { (response) in
                switch response.result {
                case .success(let rooms):
                    completion(.success(rooms))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    //GET: pk를 기준으로 특정 방 1개
    func getCertainRoomData(pk: Int, completion: @escaping (Result<DabangElement, Error>) -> Void) {
        request = AF.request( baseURL + "/posts/\(pk)/" )
        request?.responseDecodable(of: DabangElement.self) { (response) in
                switch response.result {
                case .success(let room):
                    completion(.success(room))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    //GET: pk를 기준으로 특정 방 1개 <Rx>
    func rxGetCertainRoomData(pk: Int) -> Observable<DabangElement>{
        return Observable<DabangElement>.create() { observer in
            self.getCertainRoomData(pk: pk) { (result) in
                switch result {
                case .success(let room):
                    observer.onNext(room)
                    observer.onCompleted()
                case .failure(let error):
                    print("Emitted Error")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    //GET: 최근 본 방 리스트
    func getRecentlyCheckedRooms(completion: @escaping (Result<[DabangElement], Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        self.request = AF.request( baseURL + "/members/recentlyPosts/", method: .get, headers: header)
        self.request?.responseDecodable(of: CheckedRoom.self) { (response) in
                switch response.result {
                case .success(let rooms):
                    completion(.success(rooms.posts ?? []))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    
    //GET: 찜한 방 리스트
    func getMarkedRooms(completion: @escaping (Result<[DabangElement], Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        self.request = AF.request( baseURL + "/members/postlike/", method: .get, headers: header)
        self.request?.responseDecodable(of: [DabangElement].self) { (response) in
            print("status: ", response.response?.statusCode)
                switch response.result {
                case .success(let rooms):
//                    let markedRooms = rooms.postLike?.map{$0.post} ?? []
//                    print("MarkedRooms:", markedRooms.count)
                    completion(.success(rooms))
                case .failure(let error):
                    print("MarkedRooms Failed")
                    completion(.failure(error))
                }
        }
    }
    
    //GET: 전체 단지 정보 리스트
    func getComplexInfoList(completion: @escaping (Result<[Complex], Error>) -> Void) {
        AF.request( baseURL + "/posts/complex/", method: .get)
            .responseDecodable(of: [Complex].self) { (response) in
                switch response.result {
                case .success(let complex):
                    completion(.success(complex))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    //GET: 최근 본 단지 정보 리스트
    func getRecentlyCheckedComplexList(completion: @escaping (Result<[Complex], Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        AF.request( baseURL + "/members/complexs/", method: .get, headers: header)
            .responseDecodable(of: CheckedComplex.self) { (response) in
                switch response.result {
                case .success(let complex):
                    completion(.success(complex.complexs ?? []))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    //GET: 찜한 단지 정보 리스트
    func getMarkedComplexList(completion: @escaping (Result<[Complex], Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        AF.request( baseURL + "/members/complike/", method: .get, headers: header)
            .responseDecodable(of: MarkedComplex.self) { (response) in
                switch response.result {
                case .success(let complex):
                    let markedComplex = complex.compLike?.map{$0.complexs} ?? []
                    completion(.success(markedComplex))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    //GET: 연락한 부동산 리스트
    func getContactedBrokerList(completion: @escaping (Result<[Broker], Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        AF.request( baseURL + "/members/brokers/", method: .get, headers: header)
            .responseDecodable(of: ContactedBroker.self) { (response) in
                switch response.result {
                case .success(let brokers):
                    completion(.success(brokers.brokers ?? []))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
  //MARK: -위치 기준으로 축약된 방 정보/위치 요청
  func getItemsInCurrentMap(km: Double, current position: CLLocationCoordinate2D, completion: @escaping (Result<[BangInCurrentMapModel], Error>) -> Void) {
    
    let parameter: Parameters = [
      "reqLng": position.longitude,
      "reqLat": position.latitude,
      "distance": km
    ]
    
    AF.request(baseURL + "/posts/distance/", method: .get, parameters: parameter)
      .responseDecodable(of: [BangInCurrentMapModel].self) { (response) in
        switch response.result {
        case .success(let data):
          completion(.success(data))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }
  
//  func getFilteredItems(
//    depositLoan: Bool? = nil, salesForm__type: String? = nil, type: String? = nil, min_monthlyInt: Int? = nil,
//    max_monthlyInt: Int? = nil, min_depositInt: Int? = nil, max_depositInt: Int? = nil, min_supply_area: Int? = nil,
//    max_supply_area: Int? = nil, floor: String? = nil, parkingTF: Bool? = nil, pet: Bool? = nil,
//    shortRent: Bool? = nil, elevator: Bool? = nil, builtIn: Bool? = nil, veranda: Bool? = nil,
//                        
//    completion: @escaping (Result<FilteredItemsModel, Error>) -> Void) {
//    let parameter: Parameters = [
//      "depositLoan" : depositLoan ?? "", //전세자금대출
//      "salesForm__type" : salesForm__type ?? "", //매매/월세/전세 - 중복 선택 가능
//      "type" : type ?? "", // 원룸, 투룸, 쓰리룸, 오피스텔, 아파트 중복선택 가능
//      "min_monthlyInt" : min_monthlyInt ?? "", // 월세 최소 금액
//      "max_monthlyInt" : max_monthlyInt ?? "", // 월세 최대 금액
//      "min_depositInt" : min_depositInt ?? "",// 보증금/전세가 최소 금액(매매가와 동일)
//      "max_depositInt" : max_depositInt ?? "", // 보증금/전세가 최대 금액(매매가와 동일)
//      "min_supply_area" : min_supply_area ?? "", // 최소 평수
//      "max_supply_area" : max_supply_area ?? "", // 최대 평수
//      "floor" : floor ?? "", //층수, 중복 선택 가능
//      "parkingTF" : parkingTF ?? "", //Bool값
//      "pet" : pet ?? "",//Bool값
//      "shortRent" : shortRent ?? "",//Bool값
//      "elevator" : elevator ?? "",//Bool값
//      "builtIn" : builtIn ?? "",//Bool값
//      "veranda" : veranda ?? "" //Bool값
//    ]
//    
//    AF.request(baseURL + "/posts/", method: .get, parameters: parameter)
//      .responseDecodable(of: FilteredItemsModel.self) { (response) in
//        switch response.result {
//        case .success(let data):
//          completion(.success(data))
//        case .failure(let error):
//          completion(.failure(error))
//        }
//    }
//  }
  
  func getFilteredItems(
    depositLoan: Bool? = nil, salesForm__type: String? = nil, type: String? = nil, min_monthlyInt: Int? = nil,
    max_monthlyInt: Int? = nil, min_depositInt: Int? = nil, max_depositInt: Int? = nil, min_supply_area: Int? = nil,
    max_supply_area: Int? = nil, floor: String? = nil, parkingTF: Bool? = nil, pet: Bool? = nil,
    shortRent: Bool? = nil, elevator: Bool? = nil, builtIn: Bool? = nil, veranda: Bool? = nil,
                        
    completion: @escaping (Result<FilteredItemsModel, Error>) -> Void) {
    let parameter: Parameters = [
      "depositLoan" : depositLoan ?? "", //전세자금대출
      "salesForm__type" : salesForm__type ?? "", //매매/월세/전세 - 중복 선택 가능
      "type" : type ?? "", // 원룸, 투룸, 쓰리룸, 오피스텔, 아파트 중복선택 가능
      "min_monthlyInt" : min_monthlyInt ?? "", // 월세 최소 금액
      "max_monthlyInt" : max_monthlyInt ?? "", // 월세 최대 금액
      "min_depositInt" : min_depositInt ?? "",// 보증금/전세가 최소 금액(매매가와 동일)
      "max_depositInt" : max_depositInt ?? "", // 보증금/전세가 최대 금액(매매가와 동일)
      "min_supply_area" : min_supply_area ?? "", // 최소 평수
      "max_supply_area" : max_supply_area ?? "", // 최대 평수
      "floor" : floor ?? "", //층수, 중복 선택 가능
      "parkingTF" : parkingTF ?? "", //Bool값
      "pet" : pet ?? "",//Bool값
      "shortRent" : shortRent ?? "",//Bool값
      "elevator" : elevator ?? "",//Bool값
      "builtIn" : builtIn ?? "",//Bool값
      "veranda" : veranda ?? "" //Bool값
    ]
    
    AF.request(baseURL + "/posts/", method: .get, parameters: parameter)
      .responseDecodable(of: FilteredItemsModel.self) { (response) in
        switch response.result {
        case .success(let data):
          completion(.success(data))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }
    
  
  
  //GET: 전체 분양 전체 리스트
  func getSaleAllList(completion: @escaping (Result<SaleAll, Error>) -> Void) {
    AF.request( baseURL + "/presales/", method: .get)
      .responseDecodable(of: SaleAll.self) { (response) in
        print("responseCode--->", response.response?.statusCode)
        guard let code =  response.response?.statusCode, code != 502 else {
          completion(.failure(SaleInfoError.badGatewa))
          return
        }
//        print(response.res)
        switch response.result {
        case .success(let complex):
          completion(.success(complex))
        case .failure(let error):
          completion(.failure(error))
        }
    }
    
//    guard let url = URL(string: baseURL + "/presales/") else { return }
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    let task = URLSession.shared.dataTask(with: request) {
//      (data, response, error) in
//
//      if let response = response as? HTTPURLResponse {
//        print(response.statusCode)
//      }
//
//      guard let data = data else { return }
//      let string = String(data: data, encoding: .utf8)
//      print("RESPONSE---------------------------------------")
//      print(string ?? "씨발")
//
//    }
//
//    task.resume()
    
  }
  
  //GET: 전체 분양 Tiny 리스트
  func getSaleTinyList(completion: @escaping (Result<[SaleTiny], Error>) -> Void) {
    AF.request( baseURL + "/presales/tiny", method: .get)
      .responseDecodable(of: [SaleTiny].self) { (response) in
        switch response.result {
        case .success(let complex):
          completion(.success(complex))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }
  
  
  //GET: id를 기준으로 특정 분양 1개
  func getCertainSaleData(id: Int, completion: @escaping (Result<SaleInfo, Error>) -> Void) {
    AF.request( baseURL + "/presales/" + "\(id)" + "/", method: .get)
        .responseDecodable(of: SaleInfo.self) { (response) in
      switch response.result {
      case .success(let sale):
        completion(.success(sale))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  //GET: theme를 기준으로 특정 분양정보 1개
  func getCertainThemeData(pk: Int, completion: @escaping (Result<DabangElement, Error>) -> Void) {
      let parameter = ["pk" : pk]
      AF.request( baseURL + "/posts/list/", parameters: parameter)
        .responseDecodable(of: DabangElement.self) { (response) in
              switch response.result {
              case .success(let room):
                  completion(.success(room))
              case .failure(let error):
                  completion(.failure(error))
              }
      }
  }
    // MARK: - POST
  
  
    
    //POST: 유저 생성
    func postCreteUser(username: String, password: String, email: String, profileImage: UIImage? = nil, completion: @escaping (String,Bool) -> Void) {
        let userData: [String: Any] = ["username" : username, "password" : password, "email": email]
        AF.request( baseURL + "/members/", method: .post, parameters: userData)
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let pk = json["pk"].intValue
                    let email = json["email"].stringValue
                    completion("pkNumber: \(pk)\n email: \(email)", true)
                case .failure(_):
                    let fail = "해당 사용자 이름은 이미 존재합니다."
                    completion(fail, false)
                }
        }
    }
    
    //POST: 자체 로그인
    func postUserLogin(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let loginInfo = ["email" : email, "password" : password]
        AF.request( baseURL + "/members/jwt/", method: .post, parameters: loginInfo)
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let accessToken = json["token"].stringValue
                    self.userPk = json["user"]["pk"].intValue
                    let result = self.setAccessTokenIntoKeyChain(token: accessToken, key: Key.keyChain)
                
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
  
    
    //POST: 방 내놓기
    func postRoomForSale(room: DabangElement, completion: @escaping (Result<DabangElement, Error>) -> Void) {
        AF.request( baseURL + "/posts/", method: .post, parameters: room, encoder: JSONParameterEncoder.default)
            .responseDecodable(of: DabangElement.self) { (response) in
                switch response.result {
                case .success(let room):
                    completion(.success(room))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
  
//  func postMyRoomForSale(room: DabangTinyElement, completion: @escaping ([String:Any]) -> Void) {
//
//    let encoder = JSONEncoder()
//    let jsonData = try! encoder.encode(room)
//
//    let url = baseURL
//
//    AF.request(url, method: .post, parameters: jsonData, encoder: JSONParameterEncoder.default, headers: .none, interceptor: .none, requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>)
//
//      let parameters = ["type":"투룸", "description":"원룸"]
//      AF.upload(multipartFormData: { (multipartFormData) in
//        for (key, value) in parameters {
//          multipartFormData.append(value.data(using: .utf8)!, withName: key)
//        }
//      }, to: baseURL + "/posts/create").responseJSON { response in
//        guard let json = try? JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String : Any] else { return }
//  //      guard let message = json["image"] as? String else { return }
//        completion(json)
//      }
//    }
  
  func postMyRoomForSale( completion: @escaping (Result<[String:Any], Error>) -> Void) {
    let roomDatas: [String:String] = RoomForSale.shared.roomDictionary()
    let images = RoomForSale.shared.images
    AF.upload(multipartFormData: { (MultipartFormData) in
      for (key,value) in roomDatas {
        MultipartFormData.append(value.data(using: .utf8)!, withName: key)
      }
      for image in images {
        let imageData = image.jpegData(compressionQuality: 0.50)
        MultipartFormData.append(imageData!, withName: "image", fileName: UUID().uuidString + ".png", mimeType: "image/png")
      }
    }, to: baseURL + "/posts/create/", method: .post).responseJSON { (response) in
      switch response.result {
      case .success(let data):
        completion(.success(data as! [String:Any]))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  func put(completionHandler: @escaping ([String:Any]) -> Void) {
    let userData = DabangTinyElement(pk: 50, type: .원룸, dabangTinyDescription: "테스트", address: Addresss(pk: 20, loadAddress: "", detailAddress: ""), lng: 0.00, lat: 0.00, salesForm: .none, pet: .none, elevator: false, veranda: false, depositLoan: false, postimage: [], complex: .none)
    let parameter = ["elevator" : "true", "veranda" : "false" ]
    
    let testImgData = UIImage(named: "SaleMainImage")!.jpegData(compressionQuality: 0.1)!
    let testImgData2 = UIImage(named: "AreaImage")!.jpegData(compressionQuality: 0.1)!
    
    AF.upload(multipartFormData: { (MultipartFormData) in
      MultipartFormData.append(testImgData, withName: "image", fileName: "\(Array(1111...2222).randomElement()).jpeg", mimeType: "image/jpeg")
      MultipartFormData.append(testImgData2, withName: "image", fileName: "\(Array(1111...2222).randomElement()).jpeg", mimeType: "image/jpeg")

//      for (key, value) in parameter {
//      MultipartFormData.append((UIImage(named: "SaleMainImage")?.jpegData(compressionQuality: 0.1))!, withName: "image")
//      MultipartFormData.append((UIImage(named: "SaleMainImage")?.jpegData(compressionQuality: 0.1))!, withName: "image")
//      MultipartFormData.append((UIImage(named: "SaleMainImage")?.jpegData(compressionQuality: 0.1))!, withName: "image")
//      }
    }, to: baseURL + "/posts/create/", method: .post).responseJSON { (response) in
      switch response.result {
      case .success(let data):
        print("방생성 성공")
        completionHandler(data as! [String : Any])
      case .failure(let error):
        print("방생성 실패")
        
      }
      
    }
//    AF.request(baseURL + "/posts/create/", method: .put, parameters: userData, encoder: JSONParameterEncoder.default, headers: .none, interceptor: .none).responseJSON { (response) in
//      switch response.result {
//      case .success(let userData):
//        print("방생성 성공")
//      case .failure(let error):
//        print("방생성 실패")
//        print(response.error)
//        completionHandler(.failure(error))
//      }
//    }
  }

  
    
    //POST: 최근 본 방
    func postRecentlyCheckedRoom(roomPk: Int, completion: @escaping (String) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        let parameter = ["post" : roomPk]
        AF.request( baseURL + "/members/recently/", method: .post, parameters: parameter, headers: header )
            .responseData { (response) in
                guard let json = try? JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String : Any] else { return }
                guard let message = json["message"] as? String else { return }
                completion(message)
            }
    }
    
    
    //POST: 최근 본 단지
    func postRecentlyCheckedComplex(complexPk: Int, completion: @escaping (String) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        let parameter = ["post" : complexPk]
        AF.request( baseURL + "/members/recentlyComplex/", method: .post, parameters: parameter, headers: header )
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let message = json["message"].stringValue
                    completion(message)
                case .failure(let error):
                    print(error)
                }
//                guard let json = try? JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String : Any] else { return }
//                guard let message = json["message"] as? String else { return }
//                completion(message)
            }
    }
    
  //POST: 사진 방
  func postPoto(image: UIImage, imageName : String, completion: @escaping (String) -> Void) {
    let imageData = image.jpegData(compressionQuality: 0.50)
    print(image, imageData!)
    let test = baseURL + "/posts/imageupload/"
    AF.upload(multipartFormData: { (multipartFormData) in
      multipartFormData.append(imageData!, withName: "image", fileName: imageName + ".png", mimeType: "image/png")
    }, to: test).responseJSON { response in
      guard let json = try? JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String : Any] else { return }
      guard let message = json["image"] as? String else { return }
      completion(message)
    }
  }
    
    //POST: 방 찜하기
    func postMarkRoom(roomPK: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let endPoint = baseURL + "/posts/postLike/?post=\(roomPK)"
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        AF.request(endPoint, method: .post, headers: header)
            .response { (response) in
                switch response.result {
                case .success(_):
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    
    //POST: 연락한 부동산 추가
    func postContactedBroker(brokerPK: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        let parameter = ["broker": "\(brokerPK)"]
        AF.request(baseURL + "/members/contactTo/", method: .post, parameters: parameter, headers: header)
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let message = json["message"].stringValue
                    completion(.success(message))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    //POST: 이미지 업로드
    func postPhoto(image: UIImage, imageName : String, completion: @escaping (String) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.50)
        print(image, imageData!)
        let test = baseURL + "/posts/imageupload/"
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData!, withName: "image", fileName: imageName + ".png", mimeType: "image/png")
        }, to: test).responseJSON { response in
            guard let json = try? JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String : Any] else { return }
            guard let message = json["image"] as? String else { return }
            completion(message)
        }
    }
    
    
    // MARK: - PATCH
    
    //PATCH: 유저 정보 수정
    func patchUpdateUserInfo(phone: String, username: String, completion: @escaping (Result<User, Error>) -> Void) {
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        let parameters = ["username": username, "phonenumber" : phone]
        AF.request( baseURL + "/members/\(userPk)/", method: .patch, parameters: parameters, headers: header )
            .responseDecodable(of: User.self) { (response) in
                switch response.result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
        }
    }
    
    
    // MARK: - DELETE
  
    
    //DELETE: 찜한 방 삭제
    func deleteMarkedRoom(roomPK: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let endPoint = baseURL + "/posts/postLike/?post=\(roomPK)"
        let header: HTTPHeaders = [.authorization(bearerToken: getAccessTokenFromKeyChain())]
        AF.request(endPoint, method: .delete, headers: header)
            .response { (response) in
                switch response.result {
                case .success(_):
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    
    // MARK: - Cancel Request
    
    func cancelAllRequest() {
        print("cancel All API Request")
        AF.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
}
