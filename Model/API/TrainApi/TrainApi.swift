//
//  TrainApi.swift
//  vzuh
//
//  Created by Stanislav Shelipov on 09.01.2023.
//

import SwiftUI
import Combine

struct TrainSchedule: Codable {
    var trips: [Trip] = []
    var url: String = ""
}
// MARK: - Trip
extension TrainSchedule {
    struct Trip: Codable, Identifiable {
        let id = UUID()
        let arrivalStation, arrivalTime: String
        
        let departureStation, departureTime: String
        let numberForURL, runArrivalStation, runDepartureStation, trainNumber: String
        let firm: Bool
        let name: String?
        let travelTimeInSeconds: String
        
        let categories: [Category]
        
        enum CodingKeys: String, CodingKey {
            case arrivalStation, arrivalTime, departureStation, departureTime, firm, name
            case numberForURL = "numberForUrl"
            case runArrivalStation, runDepartureStation, trainNumber , travelTimeInSeconds
            
            case categories
        }
    }
}
// MARK: - Category
extension TrainSchedule {
    struct Category: Codable {
        let price: Int
        let type: TypeEnum
    }
    
    enum TypeEnum: String, Codable {
        case coupe = "coupe"
        case lux = "lux"
        case plazcard = "plazcard"
        case sedentary = "sedentary"
        case soft = "soft"
    }
}

protocol DataTrainProtocol {
    func fetchTrainSchedule(_ location: [Route]) -> AnyPublisher<TrainSchedule, Error>
}

struct TrainApi: DataTrainProtocol {
    private func fetchData(_ url: URL) -> AnyPublisher<Data, Error> {
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .mapError{error -> Error in
                return RequestError.invalidRequest
            }
            .map(\.data)
            .timeout(.seconds(5.0),
                     scheduler: DispatchQueue.main,
                     customError: {RequestError.timeOut})
            .eraseToAnyPublisher()
    }
    
    private func decode(_ data: Data) -> AnyPublisher<TrainSchedule, Never> {
        Just(data)
            .tryMap{data -> TrainSchedule in
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(TrainSchedule.self, from: data)
                }
                catch {
                    throw RequestError.decodingError
                }
            }
            .replaceError(with: TrainSchedule())
            .map{$0}
            .eraseToAnyPublisher()
    }
    
    func fetchTrainSchedule(_ location: [Route]) -> AnyPublisher<TrainSchedule, Error> {
        location
            .publisher
//          .zip(Timer.publish(every: 0.5, on: .current, in: .common).autoconnect())
            .tryMap {
                guard let url = EndpointTrain.search(term: $0.departureStationId, term2: $0.arrivalStationId).absoluteURL
                else {
                    throw RequestError.addressUnreachable
                }
                return url
            }
            .flatMap(fetchData)
            .flatMap(decode)
            .eraseToAnyPublisher()
    }
}

extension TrainApi {
    enum EndpointTrain {
        case search(term: String, term2: String)
        case order
        
        var baseURL: URL? {
            if let baseURL = URL(string: "https://suggest.travelpayouts.com/") {
                return baseURL
            }
            return  nil
        }
        
        var path: String {
            switch self {
            case .search:
                return "search"
            case .order:
                return "order"
            }
        }
        
        var absoluteURL: URL? {
            guard let baseURL = baseURL else {
                return nil
            }
            let queryURL = baseURL.appendingPathComponent(path)
            let components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)
            guard var urlComponents = components else {
                return nil
            }
            switch self {
            case .search (let term, let term2):
                urlComponents.queryItems = [
                    URLQueryItem(name: "service", value: "tutu_trains"),
                    URLQueryItem(name: "term", value: term),
                    URLQueryItem(name: "term2", value: term2)
                ]
            default:
                urlComponents.queryItems = [URLQueryItem(name: "", value: "")]
            }
            return urlComponents.url
        }
    }
}
