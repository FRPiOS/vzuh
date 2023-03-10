//
//  EnterCitiesView.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 02.01.2023.
//

import SwiftUI

struct EnterCitiesView: View {
    @EnvironmentObject var mainVM: MainVM

    @State private var place: Place?

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Button {
                        place = .departure
                    } label: {
                        HStack {
                            Text(mainVM.departure?.name ?? "Введите место отправления")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                            Spacer()
                        }
                    }
                    Divider()
                    Button {
                        place = .arrival
                    } label: {
                        HStack {
                            Text(mainVM.arrival?.name ?? "Введите место прибытия")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                            Spacer()
                        }
                    }
                }
                Button {
                    withAnimation(.linear(duration: 0.3)) {
                        mainVM.changeCity()
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .padding()
                }
            }
        }
        .sheet(item: $place) {SearchCityView(place: $0)}
    }
}

extension EnterCitiesView {
    enum Place: Identifiable {
        case departure
        case arrival

        var id: Self {self}
    }
}

struct EnterCitiesView_Previews: PreviewProvider {
    static let mainVM = MainVM()
    static var previews: some View {
        EnterCitiesView()
            .environmentObject(mainVM)
    }
}
