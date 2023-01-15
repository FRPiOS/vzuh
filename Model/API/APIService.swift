import SwiftUI
import Combine

protocol APIServiceProtocol {
    func get<T: Decodable>(url: URL) -> AnyPublisher<T, Error>
}

enum RequestError: Error {
    case addressUnreachable
    case invalidRequest
    case decodingError
    case timeOut
}

struct APIService: APIServiceProtocol {
    
    static private func fetch(url: String) -> AnyPublisher<URL, Error> {
        Just(url)
            .tryMap {
                guard let url = URL(string: $0)
                else {
                    throw RequestError.addressUnreachable
                }
                return url
            }
            .eraseToAnyPublisher()
    }
    
    static private func fetchData(_ url: URL) -> AnyPublisher<Data, Error> {
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
    
    static private func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, Error> {
        Just(data)
            .tryMap{data -> T in
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                }
                catch {
                    throw RequestError.decodingError
                }
            }
            .map{$0}
            .eraseToAnyPublisher()
    }
    
    func get<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        Just(url)
            .flatMap(APIService.fetchData)
            .flatMap(APIService.decode)
            .eraseToAnyPublisher()
    }
}



