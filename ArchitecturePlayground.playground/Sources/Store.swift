import SwiftUI

public final class ViewStore<State, Action, Interactor: Interacting>: ObservableObject, StateHolder, Interacting  where Interactor.Action == Action {

    @Published public var state: State

    private var interactor: Interactor?

    public init(state: State) {
        self.state = state
    }

    public func setInteractor(_ interactor: Interactor) {
        self.interactor = interactor
    }

    public func handleAction(_ action: Action) {
        interactor?.handleAction(action)
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
