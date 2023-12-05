import SwiftUI

/// An illustration of clean architecture
/// respecting SwiftUI's state management

// MARK - Models

enum Home {
    struct State {
        var message: String
    }

    enum Action {
        case onAppear
    }
}

// MARK - Display

typealias HomeStore = ViewStore<Home.State, Home.Action>

struct HomeView: View {
    @StateObject var store: HomeStore

    var body: some View {
        VStack {
            Text(store.state.message)
        }.onAppear {
            store.handleAction(.onAppear)
        }
    }
}

// MARK - Business logic

class HomeInteractor: Interacting  {
    typealias Action = Home.Action

    private let presenter: HomePresenting

    init(presenter: HomePresenting) {
        self.presenter = presenter
    }

    func handleAction(_ action: Action) {
        presenter.present(message: "hello world")
    }
}

// MARK: - Presentation logic

protocol HomePresenting {
    func present(message: String)
}

class HomePresenter<Store: StateHolder>: HomePresenting where Store.State == Home.State {
    private var store: Store

    init(store: Store) {
        self.store = store
    }

    func present(message: String) {
        store.state.message = "\(message.uppercased()) 👋"
    }
}


// MARK: - Usage

// Resolving for Preview
let initialState = Home.State(message: "")
let store: HomeStore = ViewStore(state: initialState)

// Resolving for Interaction
let presenter = HomePresenter(store: store)
let interactor = HomeInteractor(presenter: presenter)
store.setInteractor(interactor)

// Testing data flow
store.handleAction(.onAppear)
print(store.state)
