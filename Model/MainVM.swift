//
//  Model.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 02.01.2023.
//

import SwiftUI
import Combine

final class MainVM: ObservableObject {
    @Published var mainMenuTabSelected: MainMenuTab = .all
    @Published var mainMenuTabSelected1: MainMenuTab1 = .all
    @Published var isSearch = false

    @Published var departure: Location?
    @Published var arrival: Location?

    @Published var dateDeparture = Date.now
    @Published var dateBack = Date.now
    @Published var isDateBack = false

    // Passengers
    private let actionPassengers: ActionPassengersProtocol
    @Published var passengers: [Passenger] = [.adult]
    @Published var actionNumberPassengers: ActionNumberPassengers?
    @Published var changeNumberPassengersError: ChangeNumberPassengersError  = .valid

    private func changeNumberPassengers() {
        var changeNumberPassengersRes: AnyPublisher<(ChangeNumberPassengersError, [Passenger]?), Never> {
            $actionNumberPassengers
                .filter {$0 != nil}
                .map {[weak self] action in
                    guard let passengers = self?.passengers else {
                        return ([.adult], action)
                    }
                    return (passengers, action)
                }
                .flatMap(actionPassengers.changeNumberPassengers)
                .eraseToAnyPublisher()
        }

        changeNumberPassengersRes
            .filter {$0.1 != nil}
            .map {$0.1!}
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$passengers)

        changeNumberPassengersRes
            .filter {$0.0 != .valid}
            .map {$0.0}
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$changeNumberPassengersError)
    }

    // Train
    typealias TrainSchedules = Result<[TrainTrip], Error>
    private let trainStationsAndRoutes: TrainStationsAndRoutesProtocol
    private let trainAPI: TrainAPIProtocol
    private let train: TrainProtocol

    @Published var trainSchedules: TrainSchedules?
    @Published var choiceSortTrainSchedules: Train.Sort?

    private func loadTrainSchedules() {
        func getTrips(_ value: (Location?, Location?)) -> AnyPublisher<[TrainTrip], Error> {
            Just(value)
                .map {($0.0!, $0.1!)}
                .flatMap(trainStationsAndRoutes.validTrainRoutes)
                .flatMap(trainAPI.getTrainSchedule)
                .eraseToAnyPublisher()
        }

        $isSearch
            .filter {$0}
            .filter {[weak self] _ in
                guard let mainMenuTabSelected = self?.mainMenuTabSelected else {
                    return false
                }
                return mainMenuTabSelected == .all
            }
            .filter {$0}
            .map {[weak self] _ in
                guard let departure = self?.departure, let arrival = self?.arrival else {
                    return (nil, nil)
                }
                return (departure, arrival)
            }
            .filter {$0.0 != nil && $0.1 != nil}
//            .flatMap(getTrips)
            .map(getTrips)
            .switchToLatest()
            .asResult()
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$trainSchedules)
    }

    private func sortTrainSchedule() {
        $choiceSortTrainSchedules
            .filter {$0 != nil}
            .map {[weak self] sort in
                switch self?.trainSchedules {
                case .success(let schedules):
                    return (schedules, sort)
                case .none:
                    return ([], nil)
                case .some(.failure):
                    return ([], nil)
                }
            }
            .filter {!$0.0.isEmpty}
            .flatMap(train.sort)
            .asResult()
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$trainSchedules)
    }

    func trainMinPrice(schedule: [TrainTrip]) -> TrainTrip? {
        train.minPrice(schedule)
    }

    init(
        actionPassengers: ActionPassengersProtocol = ActionPassengers(),
        dataTrain: TrainAPIProtocol = TrainApi(),
        dataTrainSchedule: TrainProtocol = Train(),
        trainStationsAndRoutes: TrainStationsAndRoutesProtocol = TrainStationsAndRoutes(inputFile: "tutu_routes.csv")
    ) {
        self.actionPassengers = actionPassengers
        self.trainAPI = dataTrain
        self.train = dataTrainSchedule
        self.trainStationsAndRoutes = trainStationsAndRoutes

        imagesBackground = Const.imagesBackground
        buttonsMain = Const.buttonsMain

        changeNumberPassengers()
        loadTrainSchedules()
        sortTrainSchedule()

    }

    @Published var backgroundMain = "day_snow"
    @Published var imagesBackground: [String] = []
    @Published var buttonsMain: [MainMenuTab] = []

    private struct Const {
        static let imagesBackground = ["day_snow",
                                       "snow_mountain",
                                       "day_clearsky",
                                       "day_cloudy",
                                       "night_clearsky",
                                       "tokyo-station"]

        static let buttonsMain = [MainMenuTab.all,
                                  MainMenuTab.flights,
                                  MainMenuTab.train,
                                  MainMenuTab.bus]
    }

    func convertSecondsToHrMinute(seconds: String) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru")
        formatter.calendar = calendar

        if let seconds = Int(seconds) {
            let formattedString = formatter.string(from: TimeInterval(seconds))!
            return formattedString
        } else {
            return ""
        }
    }

    func changeCity() {
        (arrival, departure) = (departure, arrival)
    }
}

extension Publisher {
    func asResult() -> AnyPublisher<Result<Output, Failure>?, Never> {
        self
            .map(Result.success)
            .catch {error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}

enum MainMenuTab {
    case all
    case hotels
    case flights
    case train
    case bus

    var imageName: String {
        switch self {
        case .all:
            return "globe"
        case .hotels:
            return "bed.double"
        case .flights:
            return "airplane"
        case .train:
            return "tram"
        case .bus:
            return "bus"
        }
    }
}
enum MainMenuTab1: CaseIterable {
    case all
    case hotels
    case flights
    case train
    case bus

    var imageName: String {
        switch self {
        case .all:
            return "globe"
        case .hotels:
            return "bed.double"
        case .flights:
            return "airplane"
        case .train:
            return "tram"
        case .bus:
            return "bus"
        }
    }
}