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

open class MainViewController: UIViewController {
    
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
    
    public lazy var headerView: HeaderView = {
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
        return isContentOverFullScreen ? 0 : calculateVisibleDimmedViewHeight()
    }
    
    private var mainOriginY: CGFloat {
        return view.frame.origin.y
    }
    
    private var isContentOverFullScreen: Bool {
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
        addHeaderView()
        makeConstraintsOfNoneScrollableContent()
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
    
    private func addHeaderView() {
        view.addSubview(headerView)
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
        switch presentationStyle {
        case .normal:
            break
        case .custom:
            isContentOverFullScreen
            ? makeConstraintsOfScrollableContent()
            : addTapGestureToDimmedView()
        case .fullScreen:
            setFullScreenStyle()
        }
        
        setHeaderViewStyle()
        setBackgroundColor()
        setDimmedViewBackgroundColor()
    }
    
    private func setHeaderViewStyle() {
        switch presentationStyle {
        case .normal:
            headerView.setSeperator()
        case .custom:
            isContentOverFullScreen ? headerView.setCloseButton() : headerView.setSeperator()
        case.fullScreen:
            headerView.setCloseButton()
        }
    }
    
    private func setBackgroundColor() {
        let color: UIColor = .white
        let bgColor: UIColor = isContentOverFullScreen ? color : .clear
        view.backgroundColor = bgColor
        contentView.backgroundColor = color
        headerView.backgroundColor = color
    }
    
    private func setDimmedViewBackgroundColor() {
        dimmedView.backgroundColor = isContentOverFullScreen ? .clear : dimmedView.backgroundColor
    }
    
    private func setFullScreenStyle() {
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
    }
    
    // MARK: - Make Constraints
    private func makeConstraintsOfScrollableContent() {
        let topInset = (presentationStyle == .normal) ? view.safeAreaInsets.top : 0
        headerView.snp.removeConstraints()
        headerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(topInset)
        }
        
        scrollView.bounces = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        contentView.snp.removeConstraints()
        contentView.removeFromSuperview()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualToSuperview()
        }
    }
    
    private func makeConstraintsOfNoneScrollableContent() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
                
        DispatchQueue.main.async {
            self.originPoint = self.contentView.frame.origin
        }
    }
    
    /// Set back to original position of the view controller
    private func resetOrigin() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin = self.originPoint
        }
    }
    
    private func dismissView() {
        self.dismiss(animated: true) {
            self.didViewDismissed()
        }
    }
    
    // MARK: - Gestures
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didViewPanned(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    private func addTapGestureToDimmedView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    private func didPanEnded(_ gesture: UIPanGestureRecognizer) {
        let dragVelocity = gesture.velocity(in: view)
        if dragVelocity.y >= 1100 {
            dismissView()
        } else if calculatePannedDistance() <= constantOfDismissableHeight {
            dismissView()
        } else {
            resetOrigin()
        }
    }
    
    private func calculatePannedDistance() -> CGFloat {
        return screenHeight - (mainOriginY + visibleDimmedHeight)
    }
    
    // MARK: - Actions
    @objc private func didDimmedViewTapped(_ gesture: UITapGestureRecognizer) {
        dismissView()
    }
    
    @objc private func didViewPanned(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        let currentPosition = translation.y
        print("*** currentPosition *** \(currentPosition)")
        switch gesture.state {
        case .changed:
            let offsetY = originPoint.y + currentPosition
            if offsetY <= view.safeAreaInsets.top {
                didPanEnded(gesture)
            } else {
                view.frame.origin = CGPoint(x: 0, y: offsetY)
            }
        case .ended:
            didPanEnded(gesture)
        default:
            break
        }
    }
    
    // MARK: - Open Methods
    open func didViewDismissed() {
        
    }
    
    // MARK: - Public Methods
}

// MARK: - HeaderViewDelegate
extension MainViewController: HeaderViewDelegate {
    public func didBackButtonTapped() {
        dismissView()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MainViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (scrollView.contentOffset.y == 0)
    }
}
