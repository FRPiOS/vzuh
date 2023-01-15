//
//  DatePick.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 01.01.2023.
//

import SwiftUI

struct DatePick: View {
    @EnvironmentObject var model: MainModel
    let isTime: DateSelectionView.IsTime?
    
    var body: some View {
        VStack {
            if isTime == .dateDeparture {
                Text((model.departure?.name ?? "") + " - " + (model.arrival?.name ?? ""))
                    .font(.largeTitle)
            } else {
                Text((model.arrival?.name ?? "") + " - " + (model.departure?.name ?? ""))
                    .font(.largeTitle)
            }
            DatePicker("",
                       selection: isTime == .dateDeparture ?
                       $model.dateDeparture: $model.dateBack,
                       in: Date.now...,
                       displayedComponents: [.date])
            .datePickerStyle(.graphical)
            Spacer()
        }
        .foregroundColor(.black)
        .padding()
        .onDisappear{
            if isTime == .dateDeparture && model.dateBack < model.dateDeparture {
                model.dateBack = model.dateDeparture
            } else if isTime == .dateBack && model.dateDeparture > model.dateBack {
                model.dateDeparture = model.dateBack
            }
        }
    }
}

struct DatePick_Previews: PreviewProvider {
    static let model = MainModel()
    static var previews: some View {
        DatePick(isTime: .dateDeparture)
            .environmentObject(model)
    }
}
