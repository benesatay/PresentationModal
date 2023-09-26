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
        view.statusBarHeight = Helper.shared.statusBarFrame.height
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
    
    // MARK: - Internal Properties
    weak var delegate: PresentationModalDelegate?
    
    // MARK: - Public Properties

    // MARK: - Private Properties
    
    private var contentViewOrigin: CGPoint = .zero
    private var headerViewOrigin: CGPoint = .zero

    private var visibleDimmedHeight: CGFloat {
        let visibleDimmedHeight = Helper.shared.calculateVisibleDimmedViewHeight(view.frame.height,
                                                                                 contentView.frame.height)
        return (presentationStyle == .fullScreen) ? 0 : visibleDimmedHeight
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
        if Helper.shared.isContentHeightOverScreen(contentView.frame.height) {
            presentationStyle = .fullScreen
        }
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
        guard let window = Helper.shared.window else { return }
        window.addSubview(dimmedView)
    }
    
    private func addHeaderView() {
        view.addSubview(headerView)
    }
    
    // MARK: - Styles
    private func setStyle() {
        switch presentationStyle {
        case .normal:
            setLayer()
            makeConstraintsOfScrollableContent()
        case .custom:
            addTapGestureToDimmedView()
        case .fullScreen:
            makeConstraintsOfScrollableContent()
        }
        
        setHeaderViewStyle()
        setBackgroundColor()
        setDimmedViewBackgroundColor()
    }
    
    private func setLayer() {
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
    }
    
    private func setHeaderViewStyle() {
        switch presentationStyle {
        case .normal:
            headerView.setSeperator()
        case .custom:
            headerView.setSeperator()
        case.fullScreen:
            headerView.setCloseButton()
        }
    }
    
    private func setDimmedViewBackgroundColor() {
        dimmedView.backgroundColor = (presentationStyle == .fullScreen) ? .clear : dimmedView.backgroundColor
    }
 
    // MARK: - Make Constraints
    private func makeConstraintsOfScrollableContent() {
        let topInset = (presentationStyle == .normal) ? Helper.shared.safeAreaInsets.top : 0
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
            self.contentViewOrigin = self.contentView.frame.origin
            self.headerViewOrigin = self.headerView.frame.origin
        }
    }
    
    /// Set back to original position of the view controller
    private func resetOrigin() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame.origin = self.contentViewOrigin
            self.headerView.frame.origin = self.headerViewOrigin
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
        let pannedDistance = Helper.shared.calculatePannedDistance(view.frame.origin.y,
                                                                   visibleDimmedHeight)
        let dragVelocity = gesture.velocity(in: view)
        print("*** pannedDistance \(pannedDistance)")
        print("*** constantOfDismissableHeight \(Helper.shared.constantOfDismissableHeight)")
        print("*** dragVelocity \(dragVelocity.y)")
        if dragVelocity.y >= 1100 {
            dismissView()
        } else if pannedDistance <= Helper.shared.constantOfDismissableHeight {
            dismissView()
        } else {
            resetOrigin()
        }
    }
    
    // MARK: - Actions
    @objc private func didDimmedViewTapped(_ gesture: UITapGestureRecognizer) {
        dismissView()
    }
    
    @objc private func didViewPanned(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else {
            if contentViewOrigin.y != contentView.frame.origin.y {
                didPanEnded(gesture)
            }
            return
        }
        let currentPosition = translation.y
        print("*** Helper.shared.safeAreaInsets.top *** \(Helper.shared.safeAreaInsets.top)")
        print("*** originPoint.y *** \(contentViewOrigin.y)")
        print("*** currentPosition *** \(currentPosition)")
        switch gesture.state {
        case .changed:
            let offsetY = contentViewOrigin.y + currentPosition
            if presentationStyle == .fullScreen,
               offsetY <= Helper.shared.safeAreaInsets.top {
                didPanEnded(gesture)
            } else {
                let headerOffsetY = headerViewOrigin.y + currentPosition
                contentView.frame.origin = CGPoint(x: 0, y: offsetY)
                headerView.frame.origin = CGPoint(x: 0, y: headerOffsetY)
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
    public final func setBackgroundColor(_ color: UIColor = .white) {
        view.backgroundColor = (presentationStyle == .fullScreen) ? color : .clear
        contentView.backgroundColor = color
        headerView.backgroundColor = color
    }
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
