//
//  PlaceListEvent.swift
//  Jabama
//
//  Created by Mohsen on 12/1/24.
//

enum PlaceListEvent {
    case changeViewType
    case loadMore
    case onSearchTextChanged(String)
    case onLocationChange(AppLocation)
    case fetchPlaces
    case changeGpsStatus(Bool)
    case changeNetworkStatus(Bool)
}
