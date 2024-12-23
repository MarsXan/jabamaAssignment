//
//  PlaceListMainViewModel.swift
//  Jabama
//
//  Created by Mohsen on 12/1/24.
//

import Foundation
import Combine

@Observable
class PlaceListMainViewModel:BaseViewModel<PlaceListEvent> {
    @ObservationIgnored
    @Inject private var apiService:PlaceListApiService
    
    private(set) var placeListState:ViewState = .loading
    private(set) var viewState:ViewState = .loading
    private(set) var places: [SearchPlace] = []
    private(set) var error:ErrorModel?
    @ObservationIgnored
    private var appLocation:AppLocation = .init(latitude: 35.7238539,longitude: 51.3575036)
    
    
    private(set) var viewType: PlaceListViewType = .list
    
    private(set) var isLocationAvailable:Bool = true
    private(set) var isNetworkAvailable:Bool = true
    
    
    
    @ObservationIgnored
    private var currentLimit:Int = 10
    
    private(set) var canLoadMore:Bool = true
    
    @ObservationIgnored
    private let searchTextPublisher = PassthroughSubject<String, Never>()
    
    @ObservationIgnored
    private let locationPublisher = PassthroughSubject<AppLocation, Never>()
    
    @ObservationIgnored
    var searchText:String = ""
    
    @ObservationIgnored
    var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        listenToChanges()
    }
    
    deinit{
        cancellables.removeAll()
    }
    
    override func onEvent(_ event: PlaceListEvent) {
        switch event {
        case .changeViewType:
            changeViewType()
        case .loadMore:
            if canLoadMore{
                Task{
                    await fetchPlaces(currentLimit + 10,isSilent: true)
                }
            }
        case .onSearchTextChanged(let query):
            onSearchTextChanged(query)
            
        case .onLocationChange(let location):
            self.onLocationChange(location)
        case .fetchPlaces:
            Task{
                await self.fetchPlaces()
            }
        case .changeGpsStatus(let isAvailable):
            self.isLocationAvailable = isAvailable
        case .changeNetworkStatus(let isAvailable):
            self.isNetworkAvailable = isAvailable
        }
    }
}

extension PlaceListMainViewModel{
    
    private func onLocationChange(_ location:AppLocation){
        self.locationPublisher.send(location)
    }
    
    private func onSearchTextChanged(_ queryText:String){
        self.canLoadMore = true
        if !queryText.isEmpty{
            self.searchTextPublisher.send(queryText)
        }else if !searchText.isEmpty{
            self.searchTextPublisher.send("")
        }
    }
    
    private func changeViewType(){
        self.viewType = viewType == .list ? .map : .list
    }
    
    @MainActor
    private func fetchPlaces(_ limit:Int = 10,isSilent:Bool = false){
        currentLimit = limit
        viewState = .loading
        if !isSilent{
            placeListState = .loading
        }
        error = nil
        let query = SearchPlaceQuery(query:searchText,ll:"\(appLocation.latitude ?? 0),\(appLocation.longitude ?? 0)", limit: currentLimit)
        Task{
            do{
                let res = try await apiService.searchPlaces(query: query).async()
                viewState = .idle
                if let placesList = res.results, !placesList.isEmpty{
                    self.places = placesList
                    self.placeListState = .idle
                    if currentLimit >= 50{
                        canLoadMore = false
                    }
                }else{
                    self.canLoadMore = false
                    self.placeListState = .empty
                    self.places.removeAll()
                }
            }catch{
                viewState = .idle
                let error = error.toModel()
                if error.code == 1000{
                    isNetworkAvailable = false
                }else{
                    self.error = error
                    self.placeListState = .error
                }
                
            }
        }
    }
    
    private func listenToChanges(){
        searchTextPublisher
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { value in
                self.searchText = value
                Task{
                    await self.fetchPlaces(isSilent: true)
                }
            }
            .store(in: &cancellables)
        
        locationPublisher
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { value in
                self.appLocation = value
                Task{
                    await self.fetchPlaces(isSilent: true)
                }
            }
            .store(in: &cancellables)
    }
}
