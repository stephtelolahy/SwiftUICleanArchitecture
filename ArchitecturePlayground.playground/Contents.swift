import SwiftUI
import Combine

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

enum Home {
    struct State {
        var message: String
    }

    enum Action {
        case onAppear
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
    var store: Store

    init(store: Store) {
        self.store = store
    }

    func present(message: String) {
        store.state.message = message
    }
}


// MARK: - Resolution

let initialState = Home.State(message: "")
let store: HomeStore = ViewStore(state: initialState)

let presenter = HomePresenter(store: store)
let interactor = HomeInteractor(presenter: presenter)
store.setInteractor(interactor: interactor)

// MARK: - Action

store.handleAction(.onAppear)
print(store.state)
