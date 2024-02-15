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

struct HomeView: View {

    typealias Store = ViewStore<Home.State, Home.Action>

    @StateObject var store: Store

    var body: some View {
        VStack {
            Text(store.state.message)
        }.onAppear {
            store.handleAction(.onAppear)
        }
    }
}

// MARK - Business logic

struct HomeInteractor: Interacting  {
    typealias Action = Home.Action

    let presenter: HomePresenting

    func handleAction(_ action: Action) {
        presenter.presentMessage("hello world")
    }
}

// MARK: - Presentation logic

protocol HomePresenting {
    func presentMessage(_ message: String)
}

struct HomePresenter: HomePresenting {
    let store: HomeView.Store

    func presentMessage(_ message: String) {
        store.state.message = "\(message.uppercased()) 👋"
    }
}

// MARK: - Usage

// Resolving for Preview
let initialState = Home.State(message: "")
let store: HomeView.Store = ViewStore(state: initialState)

// Resolving for Interaction
let presenter = HomePresenter(store: store)
let interactor = HomeInteractor(presenter: presenter)
store.setInteractor(interactor)

// Executing data flow
store.handleAction(.onAppear)
print(store.state)
