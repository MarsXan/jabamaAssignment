//
//  ProductListApiService.swift
//  Jabama
//
//  Created by Mohsen on 12/2/24.
//

import Foundation
import Combine

struct ProductListApiService: ProductListRepo {
    @Inject private var repo: ProductListRepo
    
    func searchPlaces(query: SearchPlaceQuery) -> AnyPublisher<SearchPlaceRes, ErrorModel> {
        return repo.searchPlaces(query: query)
    }
    
    
}
