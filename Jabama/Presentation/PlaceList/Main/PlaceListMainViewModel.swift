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
    
    private(set) var viewState:ViewState = .loading
    private(set) var typeSwitcherState:ViewState = .loading
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
                fetchPlaces(currentLimit + 10,isSilent: true)
            }
        case .onSearchTextChanged(let query):
            onSearchTextChanged(query)
            
        case .onLocationChange(let location):
            self.onLocationChange(location)
        case .fetchPlaces:
            self.fetchPlaces()
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
    
    private func fetchPlaces(_ limit:Int = 10,isSilent:Bool = false){
        currentLimit = limit
        typeSwitcherState = .loading
        if !isSilent{
            viewState = .loading
        }
        error = nil
        let query = SearchPlaceQuery(query:searchText,ll:"\(appLocation.latitude ?? 0),\(appLocation.longitude ?? 0)", limit: currentLimit)
        Task{
            do{
                let res = try await apiService.searchPlaces(query: query).async()
                typeSwitcherState = .idle
                if let places = res.results, !places.isEmpty{
                    self.places = places
                    self.viewState = .idle
                    if currentLimit >= 50{
                        canLoadMore = false
                    }
                }else{
                    self.canLoadMore = false
                    self.viewState = .empty
                    self.places.removeAll()
                }
            }catch{
                typeSwitcherState = .idle
                let error = error.toModel()
                if error.code == 1000{
                    isNetworkAvailable = false
                }else{
                    self.error = error
                    self.viewState = .error
                }
                
            }
        }
    }
    
    private func listenToChanges(){
        searchTextPublisher
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { value in
                self.searchText = value
                self.fetchPlaces(isSilent: true)
            }
            .store(in: &cancellables)
        
        locationPublisher
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .sink { value in
                self.appLocation = value
                self.fetchPlaces(isSilent: true)
            }
            .store(in: &cancellables)
    }
}
