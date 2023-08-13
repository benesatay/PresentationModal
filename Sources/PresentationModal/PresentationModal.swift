import UIKit

open class PresentationModal: MainView {
    
    override init(_ presentationStyle: PresentationStyle = .custom) {
        super.init(presentationStyle)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
