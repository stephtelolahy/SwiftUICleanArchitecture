import Combine

protocol CountryService {
    func loadCountries() -> AnyPublisher<Result<[String], Error>, Never>
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
        case didLoadCountriesResponse(Result<[String], Error>)
    }

    func handle(event: Event, state: inout State) -> AnyPublisher<Event, Never>? {
        switch event {
        case .didAppear:
            state = .loading
            return service.loadCountries()
                .map { .didLoadCountriesResponse($0) }
                .eraseToAnyPublisher()

        case let .didLoadCountriesResponse(.success(countries)):
            state = .loaded(countries)
            return nil

        case let .didLoadCountriesResponse(.failure(error)):
            state = .failed
            return nil
        }
    }
}
