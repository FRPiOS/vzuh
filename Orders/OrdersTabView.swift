//
//  OrdersView.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 29.12.2022.
//

import SwiftUI

struct OrdersTabView: View {
    var body: some View {
        ZStack {
            Image("day_snow")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            VStack {
                Image(systemName: "banknote")
                    .font(.largeTitle)
                    .padding(.bottom, 2)
                Text("Пока здесь пусто")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                Text("Войдите, чтобы сохранить заказ в своем профиле на Вжух. Предыдущие заказы из профиля.")
                    .lineLimit(3)

                    enterButton
            }
        }
        .tabItem {
            Image(systemName: "dollarsign.square")
            Text("Заказы")
        }
    }

    private var enterButton: some View {
            Button {
                // handle enter button tap here
            } label: {
                Text("Войти")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(.blue)
                    .cornerRadius(5)
                    .padding(.horizontal, 10)
            }
        }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersTabView()
    }
}
