//
//  EventViewController.swift
//  EventViewer
//
//  Created by Boris Kotov on 01.05.2023.
//

import UIKit

class EventViewController: UITableViewController {
    var event: DBEvent
    var properties: [(String, String)] = []
    
    private lazy var deleteBarButtonItem = UIBarButtonItem(
        title: "Delete",
        style: .plain,
        target: self,
        action: #selector(EventViewController.deleteEvent)
    )
    
    private lazy var closeBarButtonItem = UIBarButtonItem(
        title: "Close",
        style: .plain,
        target: self,
        action: #selector(EventViewController.close)
    )
    
    init(event: DBEvent) {
        self.event = event
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventPropertyCell.self, forCellReuseIdentifier: "EventPropertyCell")
        configureUI()
        fillProperties()
    }
    
    private func configureUI() {
        navigationItem.title = "Event"
        navigationItem.rightBarButtonItem = self.deleteBarButtonItem
        navigationItem.leftBarButtonItem = self.closeBarButtonItem
    }
    
    private func parameterToString(_ parameter: DBParameter, recurseIntoArrays: Bool = true) -> String? {
        var value: String?
        if !parameter.arrayValue!.isEmpty && recurseIntoArrays {
            value = "[" + parameter.arrayValue!.map {parameterToString($0, recurseIntoArrays: false) ?? "nil"}.joined(separator: ", ") + "]"
        } else if parameter.stringValue != nil && !parameter.stringValue!.isEmpty {
            value = parameter.stringValue
        } else if parameter.integerValue != nil && parameter.integerValue != 0 {
            value = String(parameter.integerValue!)
        } else if parameter.booleanValue != nil {
            value = String(parameter.booleanValue!)
        }
        return value
    }
    
    private func fillProperties() {
        properties.append(("ID", event.id))
        properties.append(("Date", event.createdAt!.description))
        
        guard let parameters = event.parameters else { return }
        
        for parameter in parameters {
            let value = parameterToString(parameter)
            if let value {
                properties.append((parameter.key, value))
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property = properties[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventPropertyCell", for: indexPath) as! EventPropertyCell
        cell.key = property.0
        cell.value = property.1
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func deleteEvent() {
        guard let navVc = presentingViewController as? UINavigationController, let listVc = navVc.viewControllers.first as? EventsListViewController else { return }
        listVc.deleteEvent(event)
        dismiss(animated: true)
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
}

class EventPropertyCell: UITableViewCell {
    private var keyLabel = UILabel()
    private var valueLabel = UILabel()

    var key: String {
        get { keyLabel.text! }
        set(newValue) { keyLabel.text = newValue }
    }
    
    var value: String {
        get { valueLabel.text! }
        set(newValue) { valueLabel.text = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        valueLabel.textColor = .secondaryLabel
        
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueLabel)
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.textAlignment = .right
        valueLabel.lineBreakMode = .byWordWrapping
        valueLabel.numberOfLines = 5
        
        NSLayoutConstraint.activate([
            keyLabel.topAnchor.constraint(equalTo: valueLabel.topAnchor),
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            keyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: keyLabel.trailingAnchor, constant: 10),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
