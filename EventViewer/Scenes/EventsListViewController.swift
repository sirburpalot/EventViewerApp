//
//  EventsListViewController.swift
//  EventViewer
//
//  Created by Ilya Kharlamov on 1/26/23.
//

import UIKit

class EventsListViewController: UITableViewController {
    
    // MARK: - Outlets
    
    private lazy var logoutBarButtonItem = UIBarButtonItem(
        title: "Logout",
        style: .plain,
        target: self,
        action: #selector(EventsListViewController.logout)
    )
    
    private lazy var addBarButtonItem = UIBarButtonItem(
        title: "Add",
        style: .plain,
        target: self,
        action: #selector(EventsListViewController.addEvent)
    )
    
    private lazy var searchController = UISearchController()
    
    // MARK: - Variables
    
    private let eventManager: EventManager
    private var events: [DBEvent] = []
    private var searchString: String?
    
    // MARK: - Lifecycle
    
    init(eventManager: EventManager) {
        self.eventManager = eventManager
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventManager.delegate = self
        tableView.register(EventListCell.self, forCellReuseIdentifier: "EventListCell")
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.delegate = self
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventManager.capture(.viewScreen("EVENTS_LIST"))
        fetchFirstPage()
    }
    
    // MARK: - Configuration
    
    private func configureUI() {
        navigationItem.title = "Events List"
        navigationItem.leftBarButtonItem = self.logoutBarButtonItem
        navigationItem.rightBarButtonItem = self.addBarButtonItem
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Actions
    
    @objc
    private func logout() {
        eventManager.capture(.logout)
        let vc = LoginViewController(eventManager: eventManager)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
 
    @objc private func addEvent() {
        let vc = AddEventViewController(eventManager: eventManager)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    // MARK: - My new funcitons
    
    var itemsPerScreen: Int { return Int(tableView.visibleSize.height) / 70 }
    var allEventsFetched = true
    
    func fetchFirstPage() {
        allEventsFetched = false
        events = eventManager.eventsSortedByDate(limit: itemsPerScreen, offset: 0, searchString: searchString)
        tableView.reloadData()
        if events.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func fetchNextPage() {
        guard !allEventsFetched else { return }
        let oldCount = events.count
        let newEvents = eventManager.eventsSortedByDate(limit: itemsPerScreen, offset: oldCount, searchString: searchString)
        guard !newEvents.isEmpty else { allEventsFetched = true; return }

        events.append(contentsOf: newEvents)
        tableView.insertRows(at: (oldCount..<(events.count)).map { IndexPath(row: $0, section: 0) }, with: .none)
    }
    
    func deleteEvent(_ event: DBEvent) {
        guard eventManager.delete(event: event) else { return }
        if let ndx = events.firstIndex(of: event) {
            events.remove(at: ndx)
            tableView.deleteRows(at: [IndexPath(row: ndx, section: 0)], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell", for: indexPath) as! EventListCell
        cell.title = event.id
        cell.date = event.createdAt?.description ?? "[no date]"
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            fetchNextPage()
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (_, _, completionHandler) in
            let result = self.eventManager.delete(event: self.events[indexPath.row])
            if result {
                self.events.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(result)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = EventViewController(event: events[indexPath.row])
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
}

extension EventsListViewController: UISearchControllerDelegate {
    
}

extension EventsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        self.searchString = !searchString.isEmpty ? searchString : nil
        self.fetchFirstPage()
    }
}

extension EventsListViewController: UISearchBarDelegate {
    
}

class EventListCell: UITableViewCell {
    private var titleLabel = UILabel()
    private var dateLabel = UILabel()

    var title: String {
        get { titleLabel.text! }
        set(newValue) { titleLabel.text = newValue }
    }
    
    var date: String {
        get { dateLabel.text! }
        set(newValue) { dateLabel.text = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        dateLabel.textColor = .secondaryLabel
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension EventsListViewController: EventManagerDelegate {
    func notifyAboutUpdate() {
        fetchFirstPage()
    }
}
