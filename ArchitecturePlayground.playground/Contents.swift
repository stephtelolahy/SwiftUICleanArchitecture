import SwiftUI

enum Home {
    struct State {
        var message: String
    }

    enum Action {
        case onAppear
    }
}

typealias HomeStore = ViewStore<Home.State, Home.Action, HomeInteractor>

struct HomeView: View {
    @StateObject var store: HomeStore

    var body: some View {
        Text(store.state.message)
            .onAppear {
                store.handleAction(.onAppear)
            }
    }
}

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

protocol HomePresenting {
    func present(message: String)
}

class HomePresenter<Store: StateHolder>: HomePresenting where Store.State == Home.State {
    private var store: Store

    init(store: Store) {
        self.store = store
    }

    func present(message: String) {
        store.state.message = message
    }
}


// MARK: - Resolution for Preview

let initialState = Home.State(message: "")
let store: HomeStore = ViewStore(state: initialState)

// MARK: - Resolution adding interaction

let presenter = HomePresenter(store: store)
let interactor = HomeInteractor(presenter: presenter)
store.setInteractor(interactor)

// MARK: - Data flow

store.handleAction(.onAppear)
print(store.state)
