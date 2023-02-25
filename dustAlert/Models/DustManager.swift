//
//  DustManager.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/08.
//

import Foundation

final class DustManager {
    
    static let shared = DustManager()
    private init() {}
    private let networkManager = NetworkManager.shared
    private let dbManager = DBManager.shared
    private var allZoneDust: [Dust] = []
    private var likeLocations: [String] = []
    private var likeDust: [Dust] = []
    
    func getMyZoneDust() -> Dust? {
        return dbManager.getMyZoneDustFromDB()
    }
    func getLikeDust() -> [Dust] {
        if likeDust.count > 0 {
            likeDust.sort { a,b in
                a.location! > b.location!
            }
        }
        return likeDust
    }
    func updateLocationsFromDB() {
        self.likeLocations = dbManager.getLikeLocationFromDB()
    }
    // 즐겨찾기한 지역으로 refetch 하는 코드
        func fetchLikeDust(completion: @escaping () -> Void) {
            updateLocationsFromDB()
            likeDust = []
            guard likeLocations.count > 0 else { return completion() }
            likeLocations.forEach { location in
                let sido = location.components(separatedBy: " ")[0]
                networkManager.fetchDust(sido) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case let .success(result):
                        let newDust = result.response.body.items.first {
                            $0.location == location
                        }!
                        self.likeDust.append(newDust)
                        completion()
                    case let .failure(error):
                        debugPrint("fetch failed. error: \(error)")
                    }
                }
            }
        }
    func getAllZoneDust() -> [Dust] {
        return allZoneDust
    }
    func fetchAllZoneDust(completion: @escaping () -> Void) {
        networkManager.fetchDust("전국"){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(result):
                self.allZoneDust = result.response.body.items
                self.syncAllZoneDust()
                completion()
            case let .failure(error):
                debugPrint("fetch failed. error: \(error)")
            }
        }
    }
    // db에 저장된, 좋아요 한 지역과 allZone에서의 좋아요 sync 맞추기
    func syncAllZoneDust() {
        guard likeLocations.count > 0 else { return }
        allZoneDust.forEach {
            if (likeLocations.contains($0.location!)) {
                $0.isLiked = true
            }
        }
    }
    
    
}
extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

