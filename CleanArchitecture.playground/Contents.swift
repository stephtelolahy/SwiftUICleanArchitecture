import Combine
import SwiftUI

// ==============================================================================================
// MARK: - Use Case
// ==============================================================================================
struct Country {
    let name: String
}

enum CountriesListEvent {
    case didAppear
}

protocol CountriesListInteractor {
    func handle(event: CountriesListEvent)
}

protocol CountriesListPresenter: AnyObject {
    func presentLoader()
    func presentCountries(_ countries: [Country])
    func presentError(_ error: Error)
}

protocol CountriesListService {
    func loadCountries() -> AnyPublisher<[Country], Error>
}

class RealCountriesListInteractor: CountriesListInteractor {
    private weak var presenter: CountriesListPresenter?
    private let service: CountriesListService
    private var subscriptions = Set<AnyCancellable>()

    init(
        presenter: CountriesListPresenter,
        service: CountriesListService
    ) {
        self.presenter = presenter
        self.service = service
    }

    func handle(event: CountriesListEvent) {
        switch event {
        case .didAppear:
            presenter?.presentLoader()
            service.loadCountries().sink { [weak self] result in
                if case let .failure(error) = result {
                    self?.presenter?.presentError(error)
                }
            } receiveValue: { [weak self] in
                self?.presenter?.presentCountries($0)
            }
            .store(in: &subscriptions)
        }
    }
}

// ==============================================================================================
// MARK: - Presentation
// ==============================================================================================

enum CountriesListViewState {
    case idle
    case loading
    case loaded([Country])
    case failed(String)
}

struct CountriesList: View {
    @StateObject private var viewModel: CountriesViewModel

    var body: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            Text("Loading ...")
        case .loaded(let countries):
            List(countries, id: \.name) {
                Text($0.name)
            }
        case .failed(let error):
            Text(error)
        }
    }
}

class CountriesViewModel: ObservableObject {
    @Published private(set) var state: CountriesListViewState
    private let interactor: CountriesListInteractor

    init(
        state: CountriesListViewState,
        interactor: CountriesListInteractor
    ) {
        self.state = state
        self.interactor = interactor
    }

    func handle(event: CountriesListEvent) {
        interactor.handle(event: event)
    }
}

extension CountriesViewModel: CountriesListPresenter {
    func presentCountries(_ countries: [Country]) {
        state = .loaded(countries)
    }

    func presentError(_ error: Error) {
        state = .failed(error.localizedDescription)
    }

    func presentLoader() {
        state = .loading
    }
}

// ==============================================================================================
// MARK: - Data
// ==============================================================================================

struct RealCountriesListService: CountriesListService {
    func loadCountries() -> AnyPublisher<[Country], Error> {
        let countries = ["France", "Belgium", "Spain"].map { Country(name: $0) }
        return Just(countries)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
