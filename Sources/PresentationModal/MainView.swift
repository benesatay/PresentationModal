//
//  MainView.swift
//
//
//  Created by Bahadır Enes Atay on 12.08.2023.
//

import UIKit

public enum PresentationStyle {
     case normal
     case custom
     case fullScreen
 }
protocol PresentationModalDelegate: AnyObject {
    
}

open class MainView: UIViewController, HeaderViewDelegate {
    
    // MARK: - Views
    private lazy var scrollView: BaseScrollView = {
        let view = BaseScrollView()
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var headerView: HeaderView = {
        let view = HeaderView()
        view.delegate = self
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.isUserInteractionEnabled = true
        view.frame.origin = .zero
        view.frame.size = UIScreen.main.bounds.size
        return view
    }()
    
    // MARK: - Public Properties
    weak var delegate: PresentationModalDelegate?
    
    // MARK: - Private Properties
    private let screenHeight = UIScreen.main.bounds.height

    private var constantOfDismissableHeight: CGFloat {
        return screenHeight/6
    }
    
    private var originPoint: CGPoint = .zero
    
    private var visibleDimmedHeight: CGFloat {
        return isOverFullScreen ? 0 : calculateVisibleDimmedViewHeight()
    }
  
    private var mainOriginY: CGFloat {
        return view.frame.origin.y
    }
    
    private var isOverFullScreen: Bool {
        switch presentationStyle {
        case .custom:
            return isContentHeightOverScreen()
        case .normal, .fullScreen:
            return true
        }
    }
    
    private var presentationStyle: PresentationStyle = .custom
    
    // MARK: - Init
    public init(_ presentationStyle: PresentationStyle = .custom) {
        self.presentationStyle = presentationStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        addPanGesture()
        addDimmedView()
        setCustomStyleContentViewConstraints()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setStyle()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.removeFromSuperview()
        }
    }
    
    // MARK: - Private Methods
    private func addDimmedView() {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        window.addSubview(dimmedView)
    }
    
    private func calculateVisibleDimmedViewHeight() -> CGFloat {
        return view.frame.height - contentView.frame.height
    }
    
    private func isContentHeightOverScreen() -> Bool {
        let totalSafeAreaInset = view.safeAreaInsets.top + view .safeAreaInsets.bottom
        let safeHeight = screenHeight - totalSafeAreaInset
        return contentView.frame.height >= safeHeight
    }
    
    // MARK: - Styles
    private func setStyle() {
        if isOverFullScreen {
            addScroll()
            switch presentationStyle {
            case .normal:
                setNormalStyle()
            case .custom:
                setOverFullScreenCustomStyle()
            case .fullScreen:
                setFullScreenStyle()
            }
        } else {
            setUnderFullScreenCustomStyle()
        }
    }
    
    private func setNormalStyle() {
        headerView.setSeperator()
    }
    
    private func setOverFullScreenCustomStyle() {
        headerView.setCloseButton()
        view.backgroundColor = .white
        dimmedView.backgroundColor = .clear
    }
    
    private func setUnderFullScreenCustomStyle() {
        addTapGesture()
        headerView.setSeperator()
    }
    
    private func setFullScreenStyle() {
        headerView.setCloseButton()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
    }
    
    private func addScroll() {
        setScrollableStyleHeaderView()
        makeScrollViewConstraints()
        makeScrollableContentViewConstraints()
    }
    
    private func makeScrollViewConstraints() {
        scrollView.bounces = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// Set back to original position of the view controller
    private func resetOrigin() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin = self.originPoint
        }
    }
    
    // MARK: - Open Methods
    open func didViewDismissed(completion: @escaping() -> Void) {
        self.dismiss(animated: true) {
            completion()
        }
    }
    

    // MARK: - PanModalHeaderViewDelegate
    open func didBackButtonTapped() {
        didViewDismissed {}
    }
    
    open func setSeperatorStyle(_ view: UIView) {
        
    }
    
    open func setCloseButtonStyle(_ button: UIButton) {
        
    }
    
    // MARK: - Public Methods

}

// MARK: - UIGestureRecognizerDelegate
extension MainView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (scrollView.contentOffset.y == 0)
    }
}

// MARK: - Gestures
extension MainView {
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didViewPanned(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    private func didPanEnded(_ gesture: UIPanGestureRecognizer) {
        let dragVelocity = gesture.velocity(in: view)
        if dragVelocity.y >= 1100 {
            self.didViewDismissed {}
        } else if calculatePannedDistance() <= constantOfDismissableHeight {
            self.didViewDismissed {}
        } else {
            resetOrigin()
        }
    }
    
    private func calculatePannedDistance() -> CGFloat {
        return screenHeight - (mainOriginY + visibleDimmedHeight)
    }
    
    // MARK: - Actions
    @objc private func didDimmedViewTapped(_ gesture: UITapGestureRecognizer) {
        didViewDismissed {}
    }
    
    @objc private func didViewPanned(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        let currentPosition = translation.y
        //        tnLog("*** currentPosition *** \(currentPosition)")
        switch gesture.state {
        case .changed:
            view.frame.origin = CGPoint(x: 0, y: originPoint.y + currentPosition)
        case .ended:
            didPanEnded(gesture)
        default:
            break
        }
    }
}

// MARK: - Content View
extension MainView {
    private func makeScrollableContentViewConstraints() {
        contentView.snp.removeConstraints()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualToSuperview()
        }
    }
    
    private func setCustomStyleContentViewConstraints() {
        contentView.backgroundColor = presentationStyle == .fullScreen ? .clear : .white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        setCustomStyleHeaderView()
        
        DispatchQueue.main.async {
            self.originPoint = self.contentView.frame.origin
        }
    }
}

// MARK: - Header View
extension MainView {
    private func setCustomStyleHeaderView() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setScrollableStyleHeaderView() {
        headerView.snp.removeConstraints()
        headerView.snp.makeConstraints { make in
            switch presentationStyle {
            case .custom, .fullScreen:
                make.top.equalToSuperview()
            case .normal:
                make.top.equalToSuperview().inset(view.safeAreaInsets.top)
            }
            make.leading.trailing.equalToSuperview()
        }
    }
}
