import SwiftUI

public final class ViewStore<State, Action>: ObservableObject, StateHolder, Interacting {

    @Published public var state: State

    private var interactor: (any Interacting)?

    public init(state: State) {
        self.state = state
    }

    public func setInteractor<Interactor: Interacting>(_ interactor: Interactor) where Interactor.Action == Action {
        self.interactor = interactor
    }

    public func handleAction(_ action: Action) {
        guard let interactor = self.interactor as? any Interacting<Action> else {
            return
        }

        interactor.handleAction(action)
    }
}

public protocol Interacting<Action> {
    associatedtype Action

    func handleAction(_ action: Action)
}

public protocol StateHolder: AnyObject {
    associatedtype State

    var state: State { get set }
}
