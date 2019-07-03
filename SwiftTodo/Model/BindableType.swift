import UIKit
import RxSwift

protocol BindableType {
  associatedtype ViewModelType
  
  var viewModel: ViewModelType! { get set }

  func bindViewModel()
}

extension BindableType where Self: UIViewController {
  mutating func bindViewModel(to model: Self.ViewModelType) {
    viewModel = model
    loadViewIfNeeded()
    bindViewModel()
  }
}
