//
//  ActionPassengers.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 26.01.2023.
//

import SwiftUI
import Combine

protocol ActionPassengersProtocol {
    func changeNumberPassengers(_ passengers: ([Passenger], ActionNumberPassengers?))
    -> AnyPublisher<(ChangeNumberPassengersError, [Passenger]?), Never>
}

struct ActionPassengersModel: ActionPassengersProtocol {
    private func addAdult(_ passengers: [Passenger]) -> (ChangeNumberPassengersError, [Passenger]?) {
        if passengers.count + 1 > Const.maxNumberPassengers {
            return (.lotsPassengers, nil)
        }
        return (.valid, passengers + [.adult])
    }

    private func removeAdult(_ passengers: [Passenger]) -> (ChangeNumberPassengersError, [Passenger]?) {
        guard passengers.filter({$0 == .adult}).count - 1 >= 1 else {
            return (.fewPassengers, nil)
        }
        guard passengers.filter({$0 == .adult}).count - 1 >= passengers.filter({$0 == .baby}).count else {
            return (.fewerAdultsThanBabies, nil)
        }
        var arr = passengers
        if let index = arr.firstIndex(of: .adult) {
            arr.remove(at: index)
        }
        return (.valid, arr)
    }

    private func addChild(_ passengers: [Passenger]) -> (ChangeNumberPassengersError, [Passenger]?) {
        var arr = passengers
        arr.append(.child)
        return (.valid, arr)
    }

    private func removeChild(_ passengers: [Passenger]) -> (ChangeNumberPassengersError, [Passenger]?) {
        var arr = passengers
        if let index = arr.firstIndex(of: .child) {
            arr.remove(at: index)
        }
        return (.valid, arr)
    }

    private func addBaby(_ passengers: [Passenger]) -> (ChangeNumberPassengersError, [Passenger]?) {
        guard passengers.filter({$0 == .baby}).count + 1 <= passengers.filter({$0 == .adult}).count else {
            return (.lotsBabies, nil)
        }
        var arr = passengers
        arr.append(.baby)
        return (.valid, arr)
    }

    private func removeBaby(_ passengers: [Passenger]) -> (ChangeNumberPassengersError, [Passenger]?) {
        var arr = passengers
        if let index = arr.firstIndex(of: .baby) {
            arr.remove(at: index)
        }
        return (.valid, arr)
    }

    func changeNumberPassengers(_ passengers: ([Passenger], ActionNumberPassengers?))
    -> AnyPublisher<(ChangeNumberPassengersError, [Passenger]?), Never> {
        Just(passengers)
            .filter {$0.1 != nil}
            .map {
                switch $0.1! {
                case .addAdult:
                    return addAdult($0.0)

                case .removeAdult:
                    return removeAdult($0.0)

                case .addChild:
                    return addChild($0.0)

                case .removeChild:
                    return removeChild($0.0)

                case .addBaby:
                    return addBaby($0.0)

                case .removeBaby:
                    return removeBaby($0.0)
                }
            }
            .eraseToAnyPublisher()
    }

    private struct Const {
        static let maxNumberPassengers = 4
    }
}

enum Passenger: Hashable, CaseIterable, Identifiable {
    case adult
    case child
    case baby

    var id: Self {self}

    var description: String {
        switch self {
        case .adult:
            return "12 - 120 ??????"
        case .child:
            return "2 - 11 ??????"
        case .baby:
            return "0 - 1 ??????"
        }
    }
}

enum ActionNumberPassengers {
    case addAdult
    case removeAdult
    case addChild
    case removeChild
    case addBaby
    case removeBaby
}

enum ChangeNumberPassengersError: String {
    case lotsPassengers = "?????????? ?????????????? ???? ????????????, ?????? ???????????? ??????????????????!"
    case fewPassengers = "?????????? ?????????????? ???? ?????????? ???????????? ?????????????????? ??????????????????!"
    case fewerAdultsThanBabies = "???????????????? ???? ?????????? ???????? ????????????, ?????? ?????????? ???????????? ???????? ??????!"
    case lotsBabies = "?????????? ???? ???????? ?????? ???????????? ???????? ???? ????????????, ?????? ????????????????!"
    case valid
}
