//
//  MainView.swift
//  MediaManipulation
//
//  Created by Nurlan Akylbekov  on 27.08.2022.
//

import UIKit

final class MainView: UIView {
  
  // MARK: - Public properties
  
  var didTapAdd: (() -> Void)?
  var didTapCut: (() -> Void)?
  var didTapDivide: (() -> Void)?
  var didTapPlay: (() -> Void)?
  
  lazy var isPlaying: Bool = false {
    didSet {
      let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
      let image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill", withConfiguration: config)
      playButton.setImage(image, for: .normal)
    }
  }
  
  lazy var isControlHidden: Bool = false {
    didSet {
      playButton.isHidden = isControlHidden
    }
  }
  
  // MARK: - Private properties
  
  private lazy var addVideoButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("Add Video", for: .normal)
    btn.setTitleColor(.white, for: .normal)
    btn.backgroundColor = .systemTeal
    btn.layer.cornerRadius = 8
    btn.addTarget(self, action: #selector(didTapAddBtn), for: .touchUpInside)
    return btn
  }()
  
  private lazy var editVideoButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("Edit", for: .normal)
    btn.tintColor = .white
    btn.backgroundColor = .systemPink
    btn.layer.cornerRadius = 8
    btn.isHidden = true
    btn.addTarget(self, action: #selector(didTapCutBtn), for: .touchUpInside)
    return btn
  }()
  
  private lazy var divideVideoButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("Divide For 2", for: .normal)
    btn.tintColor = .white
    btn.backgroundColor = .systemPink
    btn.layer.cornerRadius = 8
    btn.isHidden = true
    btn.addTarget(self, action: #selector(didTapDivideBtn), for: .touchUpInside)
    return btn
  }()
  
  private lazy var playButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
    let image = UIImage(systemName: "play.fill", withConfiguration: config)
    btn.setImage(image, for: .normal)
    btn.tintColor = .white.withAlphaComponent(0.4)
    btn.backgroundColor = .clear
    btn.addTarget(self, action: #selector(didTapPlayBtn), for: .touchUpInside)
    return btn
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Actions

private extension MainView {
  @objc private func didTapAddBtn() {
    didTapAdd?()
  }
  
  @objc private func didTapCutBtn() {
    didTapCut?()
  }
  
  @objc private func didTapDivideBtn() {
    didTapDivide?()
  }
  
  @objc private func didTapPlayBtn() {
    didTapPlay?()
  }
  
  @objc private func didTapVideo() {
    isControlHidden = false
    if self.isPlaying {
      hideControls()
    }
  }
}

// MARK: - Layout

private extension MainView {
  private func setupView() {
    addSubview(addVideoButton)
    addSubview(editVideoButton)
    addSubview(divideVideoButton)
    
    constraintView()
  }
  
  private func constraintView() {
    NSLayoutConstraint.activate([
      addVideoButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
      addVideoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      addVideoButton.heightAnchor.constraint(equalToConstant: 40),
      addVideoButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
      
      editVideoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      editVideoButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
      editVideoButton.bottomAnchor.constraint(equalTo: addVideoButton.topAnchor, constant: -10),
      editVideoButton.heightAnchor.constraint(equalToConstant: 40),
      
      divideVideoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      divideVideoButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
      divideVideoButton.bottomAnchor.constraint(equalTo: editVideoButton.topAnchor, constant: -10),
      divideVideoButton.heightAnchor.constraint(equalToConstant: 40)
    ])
  }
}

// MARK: - Public functions

extension MainView {
  func addVideoView(videoView: UIView, overlayView: UIView) {
    addSubview(videoView)
    
    videoView.translatesAutoresizingMaskIntoConstraints = false
    videoView.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapVideo))
    videoView.addGestureRecognizer(tap)
    
    NSLayoutConstraint.activate([
      videoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      videoView.leadingAnchor.constraint(equalTo: leadingAnchor),
      videoView.trailingAnchor.constraint(equalTo: trailingAnchor),
      videoView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
    ])
    
    overlayView.addSubview(playButton)
    
    NSLayoutConstraint.activate([
      playButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 15),
      playButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -15)
    ])
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIView.animate(withDuration: 0.3) {
        self.editVideoButton.isHidden = false
        self.divideVideoButton.isHidden = false
        self.layoutIfNeeded()
      }
    }
    
  }
  
  func removeVideoView(videoView: UIView) {
    videoView.removeFromSuperview()
  }
  
  func hideControls() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      self.isControlHidden = true
    }
  }
}
