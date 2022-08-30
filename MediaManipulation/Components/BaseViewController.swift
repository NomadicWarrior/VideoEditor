//
//  BaseViewController.swift
//  MediaManipulation
//
//  Created by Nurlan Akylbekov  on 29.08.2022.
//

import UIKit

class BaseViewController: UIViewController {

  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
  }
  
  func showError(with error: Error) {
    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)
    
    present(alertController, animated: true, completion: nil)
  }
}
