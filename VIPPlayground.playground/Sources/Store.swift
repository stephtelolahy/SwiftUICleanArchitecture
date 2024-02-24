import SwiftUI

public final class ViewStore<State, Action>: ObservableObject, Interacting {

    @Published public var state: State

    private var interactor: (any Interacting)?

    public init(state: State) {
        self.state = state
    }

    public func handleAction(_ action: Action) {
        guard let interactor = self.interactor as? any Interacting<Action> else {
            return
        }

        interactor.handleAction(action)
    }

    public func setInteractor<T: Interacting>(_ interactor: T) where T.Action == Action {
        self.interactor = interactor
    }
}

public protocol Interacting<Action> {
    associatedtype Action

    func handleAction(_ action: Action)
}
