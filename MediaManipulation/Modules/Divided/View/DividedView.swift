//
//  DividedView.swift
//  MediaManipulation
//
//  Created by Nurlan Akylbekov  on 29.08.2022.
//

import UIKit

final class DividedView: UIView {
  
  // MARK: - Public properties
  
  var dismiss: (() -> Void)?
  var swipe: (() -> Void)?

  // MARK: - Private properties
  
  private lazy var closeButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
    let img = UIImage(systemName: "xmark", withConfiguration: config)
    btn.setImage(img, for: .normal)
    btn.tintColor = .lightGray
    btn.addTarget(self, action: #selector(didTapCloseBtn), for: .touchUpInside)
    return btn
  }()
  
  private lazy var swipeButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
    let img = UIImage(systemName: "xmark", withConfiguration: config)
    btn.setImage(img, for: .normal)
    btn.tintColor = .systemPink
    btn.addTarget(self, action: #selector(didTapSwipeBtn), for: .touchUpInside)
    return btn
  }()
  
  let stackView: UIStackView = {
    let view = UIStackView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.distribution = .fillEqually
    view.spacing = 40
    view.isHidden = true
    return view
  }()
  
  private let indicator: UIActivityIndicatorView = {
    let ind = UIActivityIndicatorView()
    ind.translatesAutoresizingMaskIntoConstraints = false
    ind.style = .large
    ind.color = .systemPink
    ind.hidesWhenStopped = true
    return ind
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    indicator.startAnimating()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addVideoViews(_ view: UIView) {
    stackView.addArrangedSubview(view)
    
    if stackView.arrangedSubviews.count > 1 {
      indicator.stopAnimating()
      stackView.isHidden = false
    }
  }
  
}

// MARK: - Layout

private extension DividedView {
  private func setupView() {
    addSubview(closeButton)
    addSubview(stackView)
    addSubview(indicator)
    constraintView()
  }
  
  private func constraintView() {
    NSLayoutConstraint.activate([
      closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
      
      stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
      indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }
}

// MARK: - Private Actions

private extension DividedView {
  @objc private func didTapCloseBtn() {
    dismiss?()
  }
  
  @objc private func didTapSwipeBtn() {
    swipe?()
  }
}
