//
//  NetworkManager.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/06.
//

import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    typealias SidoDustNetworkCompletion = (Result<DustData, Error>) -> Void
    typealias DangerZoneDustNetworkCompletion = (Result<DangerZoneDustData, Error>) -> Void
    func fetchDust(_ sidoName: String, completionHandler: @escaping SidoDustNetworkCompletion) {
        let URL = Const.SIDO_DUST_URL
        let params = [
            "sidoName": sidoName,
            "serviceKey": Env.apiKey,
            "returnType": "json",
            "numOfRows": "100",
            "pageNo": "1",
            "ver": "1.0",
        ]

        AF.request(URL, method: .get, parameters: params).responseData(completionHandler:  { response in
            switch response.result {

            case let .success(data):
                do {
                    let result = try JSONDecoder().decode(DustData.self, from: data)
                    completionHandler(.success(result))
                } catch {
                    completionHandler(.failure(error))
                }
            case let .failure(error):
                completionHandler(.failure(error))
            }
        })
    }
    
    func fetchDangerZoneDust(completionHandler: @escaping DangerZoneDustNetworkCompletion) {
        let URL = Const.DANGER_ZONE_DUST_URL
        let params = [
            "serviceKey": Env.apiKey,
            "returnType": "json",
            "numOfRows": "100",
            "pageNo": "1",
        ]

        AF.request(URL, method: .get, parameters: params).responseData(completionHandler:  { response in
            switch response.result {
            case let .success(data):
                do {
                    let result = try JSONDecoder().decode(DangerZoneDustData.self, from: data)
                    completionHandler(.success(result))
                } catch {
                    completionHandler(.failure(error))
                }
            case let .failure(error):
                completionHandler(.failure(error))
            }
        })
    }
    
    
}
