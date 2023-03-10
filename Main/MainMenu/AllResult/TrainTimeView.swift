//
//  DepArrView.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 17.01.2023.
//

import SwiftUI

struct TrainTimeView: View {
    @EnvironmentObject var mainVM: MainVM
    @EnvironmentObject var searchingCities: SearchingCities
    let trip: TrainTrip

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(trip.departureTime.dropLast(3))
                    .font(.title)
                    .fontWeight(.bold)
                Text(searchingCities.stationName(trip.departureStation))
                    .font(.callout)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
            VStack(alignment: .leading) {
                Text(trip.arrivalTime.dropLast(3))
                    .font(.title)
                    .fontWeight(.bold)
                Text(searchingCities.stationName(trip.arrivalStation))
                    .font(.callout)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
            VStack(alignment: .leading) {
                Text(mainVM.convertSecondsToHrMinute(seconds: trip.travelTimeInSeconds))
                    .lineLimit(2)
                Text("в пути")
                Spacer()
            }
            .font(.callout)
        }
    }
}

// struct DepArrView_Previews: PreviewProvider {
//    static let model = MainModel()
//    static let searching = SearchingCities()
//    static var previews: some View {
//        DepArrView()
//            .environmentObject(model)
//            .environmentObject(searching)
//    }
// }
