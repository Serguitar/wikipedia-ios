import UIKit

protocol DiffToolbarViewDelegate: AnyObject {
    func tappedPrevious()
    func tappedNext()
    func tappedShare(_ sender: UIBarButtonItem)
    func tappedThankButton()
    func tappedUndo()
    func tappedRollback()
    var isLoggedIn: Bool { get }
}

class DiffToolbarView: UIView {
    
    var parentViewState: DiffContainerViewModel.State? {
        didSet {
            apply(theme: theme)
        }
    }
    
    private var theme: Theme = .standard
    
    @IBOutlet private var toolbar: UIToolbar!
    @IBOutlet var contentView: UIView!
    lazy var previousButton: IconBarButtonItem = {
        let item = IconBarButtonItem(iconName: "chevron-down", target: self, action: #selector(tappedPrevious(_:)), for: .touchUpInside)
        item.accessibilityLabel = WMFLocalizedString("action-previous-revision-accessibility", value: "Previous Revision", comment: "Accessibility title for the 'Previous Revision' action button when viewing a single revision diff.")
        item.customView?.widthAnchor.constraint(equalToConstant: 38).isActive = true
        return item
    }()

    lazy var nextButton: IconBarButtonItem = {
        let item = IconBarButtonItem(iconName: "chevron-up", target: self, action: #selector(tappedNext(_:)), for: .touchUpInside)
        item.accessibilityLabel = WMFLocalizedString("action-next-revision-accessibility", value: "Next Revision", comment: "Accessibility title for the 'Next Revision' action button when viewing a single revision diff.")
        item.customView?.widthAnchor.constraint(equalToConstant: 38).isActive = true
        return item
    }()

    lazy var moreButton: IconBarButtonItem = {
        // DIFFTODO: Add menu item images
        let menu = UIMenu(title: "", options: .displayInline, children: [
                UIAction(title: CommonStrings.rollback, attributes: [.destructive], handler: { [weak self] _ in self?.tappedRollback() }),
                UIAction(title: CommonStrings.shortShareTitle, image: UIImage(systemName: "square.and.arrow.up"), handler: { _ in }),
                // DIFFTODO: Add when Watchlist ships
                // UIAction(title: CommonStrings.watchlist, handler: { _ in }),
                UIAction(title: CommonStrings.diffArticleEditHistory, handler: { _ in })
            ]
        )
        
        let item = IconBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)

        item.accessibilityLabel = CommonStrings.moreButton
        return item
    }()

    lazy var undoButton: IconBarButtonItem = {
        let item = IconBarButtonItem(iconName: "Revert", target: self, action: #selector(tappedUndo(_:)), for: .touchUpInside)
        item.accessibilityLabel = CommonStrings.undo
        return item
    }()

    lazy var shareButton: IconBarButtonItem = {
        let item = IconBarButtonItem(iconName: "share", target: self, action: #selector(tappedShare(_:)), for: .touchUpInside)
        item.accessibilityLabel = CommonStrings.accessibilityShareTitle

        return item
    }()

    lazy var thankButton: IconBarButtonItem = {
        let item = IconBarButtonItem(iconName: "diff-smile", target: self, action: #selector(tappedThank(_:)), for: .touchUpInside , iconInsets: UIEdgeInsets(top: 5.0, left: 0, bottom: -5.0, right: 0))
        item.accessibilityLabel = WMFLocalizedString("action-thank-user-accessibility", value: "Thank User", comment: "Accessibility title for the 'Thank User' action button when viewing a single revision diff.")
        
        return item
    }()
    
    weak var delegate: DiffToolbarViewDelegate?
    var isThankSelected = false {
        didSet {
            
            let imageName = isThankSelected ? "diff-smile-filled" : "diff-smile"
            if let button = thankButton.customView as? UIButton {
                button.setImage(UIImage(named: imageName), for: .normal)
            }
        }
    }
    
    var toolbarHeight: CGFloat {
        return toolbar.frame.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(DiffToolbarView.wmf_nibName(), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        setItems()
    }

    @objc func tappedUndo(_ sender: UIBarButtonItem) {
        delegate?.tappedUndo()
    }

    @objc func tappedRollback() {
        delegate?.tappedRollback()
    }
    
    @objc func tappedPrevious(_ sender: UIBarButtonItem) {
        delegate?.tappedPrevious()
    }
    
    @objc func tappedNext(_ sender: UIBarButtonItem) {
        delegate?.tappedNext()
    }
    
    @objc func tappedShare(_ sender: UIBarButtonItem) {
        delegate?.tappedShare(shareButton)
    }
    
    @objc func tappedThank(_ sender: UIBarButtonItem) {
        delegate?.tappedThankButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setItems()
    }

    private func setItems() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [nextButton, flexibleSpace, previousButton, flexibleSpace, undoButton, flexibleSpace, thankButton, flexibleSpace, moreButton]
    }
    
    func setPreviousButtonState(isEnabled: Bool) {
        previousButton.isEnabled = isEnabled
    }
    
    func setNextButtonState(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
    }
    
    func setThankButtonState(isEnabled: Bool) {
        thankButton.isEnabled = isEnabled
    }
    
    func setShareButtonState(isEnabled: Bool) {
        shareButton.isEnabled = isEnabled
    }
}

extension DiffToolbarView: Themeable {
    func apply(theme: Theme) {
        
        self.theme = theme
        
        toolbar.isTranslucent = false
        
        toolbar.backgroundColor = theme.colors.chromeBackground
        toolbar.barTintColor = theme.colors.chromeBackground
        contentView.backgroundColor = theme.colors.chromeBackground
        
        // avoid toolbar disappearing when empty/error states are shown
        if theme == Theme.black {
            switch parentViewState {
            case .error, .empty:
                    toolbar.backgroundColor = theme.colors.paperBackground
                    toolbar.barTintColor = theme.colors.paperBackground
                    contentView.backgroundColor = theme.colors.paperBackground
            default:
                break
            }
        }
        
        previousButton.apply(theme: theme)
        nextButton.apply(theme: theme)
        shareButton.apply(theme: theme)
        undoButton.apply(theme: theme)
        thankButton.apply(theme: theme)
        moreButton.apply(theme: theme)
        
        if let delegate = delegate,
            !delegate.isLoggedIn {
            if let button = thankButton.customView as? UIButton {
                button.tintColor = theme.colors.disabledLink
            }
        }
        shareButton.tintColor = theme.colors.link
    }
}
