//
//  PlaceListMarkersView.swift
//  Jabama
//
//  Created by Mohsen on 12/2/24.
//

import SwiftUI
import MapKit

struct MapMarkerListView: View {
    @Binding var cameraPosition: MapCameraPosition
    @Environment(PlaceListMainViewModel.self) var mainViewModel
    @Environment(PlaceListMapViewModel.self) var mapViewModel
    var extraAction:(SearchPlace)->Void = {_ in }
    
    var body: some View {
        Map(position:$cameraPosition){
            ForEach(mainViewModel.places,id: \.id){place in
                Annotation("", coordinate: place.geoLocation()) {
                    CustomMarkerView(score:place.score())
                        .onTapGesture {
                            mapViewModel.onEvent(.onPlaceSelcted(place))
                            extraAction(place)
                        }
                }.tag(place.id)
            }
        }
    }
}

#Preview {
    @Previewable @State var mainViewModel: PlaceListMainViewModel = .init()
    @Previewable @State var mapViewModel: PlaceListMapViewModel = .init()
    @Previewable @State var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    MapMarkerListView(cameraPosition: $cameraPosition)
        .environment(mainViewModel)
        .environment(mapViewModel)
}