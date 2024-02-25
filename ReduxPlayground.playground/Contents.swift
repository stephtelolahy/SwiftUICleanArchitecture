import Combine

protocol CountryService {
    func loadCountries() -> AnyPublisher<[String], Error>
}

struct CountriesReducer {

    private let service: CountryService

    enum State {
        case idle
        case loading
        case loaded([String])
        case failed
    }

    enum Event {
        case didAppear
        case didFinishLoadCountries(Result<[String], Error>)
    }

    func handle(event: Event, state: inout State) -> AnyPublisher<Event, Never>? {
        switch event {
        case .didAppear:
            state = .loading
            return service.loadCountries()
                .toResult()
                .map { .didFinishLoadCountries($0) }
                .eraseToAnyPublisher()

        case let .didFinishLoadCountries(.success(countries)):
            state = .loaded(countries)
            return nil

        case let .didFinishLoadCountries(.failure(error)):
            state = .failed
            return nil
        }
    }
}

extension AnyPublisher {
    func toResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map { Result.success($0) }
        .catch { Just(Result.failure($0)) }
        .eraseToAnyPublisher()
    }
}

enum APIError: Error {
    case unknown
}
