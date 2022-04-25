import UIKit
import WMF
import SwiftUI

final class NotificationsCenterDetailViewController: ViewController {

    // MARK: - Properties

    var detailView: NotificationsCenterDetailView {
        return view as! NotificationsCenterDetailView
    }

    let viewModel: NotificationsCenterDetailViewModel

    // MARK: - Lifecycle

    init(theme: Theme, viewModel: NotificationsCenterDetailViewModel) {
        self.viewModel = viewModel
        super.init(theme: theme)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let detailView = NotificationsCenterDetailView(frame: UIScreen.main.bounds)
        view = detailView
        scrollView = detailView.tableView

        detailView.tableView.dataSource = self
        detailView.tableView.delegate = self
    }

    // MARK: - Themeable

    override func apply(theme: Theme) {
        super.apply(theme: theme)

        detailView.apply(theme: theme)
    }

}

// MARK: - UITableView

extension NotificationsCenterDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsCenterDetailHeaderCell.reuseIdentifier) as? NotificationsCenterDetailHeaderCell ?? NotificationsCenterDetailHeaderCell()
                cell.configure(viewModel: viewModel, theme: theme)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsCenterDetailContentCell.reuseIdentifier) as? NotificationsCenterDetailContentCell ?? NotificationsCenterDetailContentCell()
                cell.configure(viewModel: viewModel, theme: theme)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsCenterDetailActionCell.reuseIdentifier) as? NotificationsCenterDetailActionCell ?? NotificationsCenterDetailActionCell()
                cell.configure(action: viewModel.primaryAction, theme: theme)
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsCenterDetailActionCell.reuseIdentifier) as? NotificationsCenterDetailActionCell ?? NotificationsCenterDetailActionCell()
            cell.configure(action: viewModel.secondaryActions[indexPath.row], theme: theme)
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if viewModel.primaryAction != nil {
                return 3
            }

            return 2
        default:
            return viewModel.secondaryActions.count
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let actionCell = tableView.cellForRow(at: indexPath) as? NotificationsCenterDetailActionCell else {
            return
        }

        if let actionData = actionCell.action?.actionData, let url = actionData.url {
            logNotificationInteraction(with: actionCell.action)
            navigate(to: url)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func logNotificationInteraction(with action: NotificationsCenterAction?) {
        let notification = viewModel.commonViewModel.notification
        if let notificationId = notification.id, let notificationWiki = notification.wiki, let notificationType = notification.typeString {
        RemoteNotificationsFunnel.shared.logNotificationInteraction(
            notificationId: Int(notificationId) ?? Int(),
            notificationWiki: notificationWiki,
            notificationType: notificationType,
            action: action?.actionData?.actionType,
            selectionToken: nil)
        }
    }

}
