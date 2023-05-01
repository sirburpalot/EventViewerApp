//
//  AddEventViewController.swift
//  EventViewer
//
//  Created by Boris Kotov on 01.05.2023.
//

import UIKit

class AddEventViewController: UIViewController {
    private lazy var addBarButtonItem = UIBarButtonItem(
        title: "Add",
        style: .plain,
        target: self,
        action: #selector(AddEventViewController.addEvent)
    )
    
    private lazy var cancelBarButtonItem = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(AddEventViewController.cancel)
    )
    
    private var eventManager: EventManager
    
    private var idLabel = UILabel()
    private var dateLabel = UILabel()
    private var parametersLabel = UILabel()
    
    private var idInput = UITextField()
    private var dateInput = UIDatePicker()
    private var parametersInput = UITextView()
    
    init(eventManager: EventManager) {
        self.eventManager = eventManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        self.view.backgroundColor = .systemGray6
        idInput.backgroundColor = .systemBackground
        idInput.borderStyle = .roundedRect
        
        idLabel.text = "ID:"
        dateLabel.text = "Date:"
        parametersLabel.text = "Parameters (JSON):"
        
        parametersInput.smartQuotesType = .no
        
        view.addSubview(idLabel)
        view.addSubview(idInput)
        view.addSubview(dateLabel)
        view.addSubview(dateInput)
        view.addSubview(parametersLabel)
        view.addSubview(parametersInput)
        
        for v in [idLabel, dateLabel, parametersLabel, idInput, dateInput, parametersInput] {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            idLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            idInput.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: idInput.bottomAnchor, constant: 20),
            dateInput.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            parametersLabel.topAnchor.constraint(equalTo: dateInput.bottomAnchor, constant: 20),
            parametersInput.topAnchor.constraint(equalTo: parametersLabel.bottomAnchor, constant: 10),
            parametersInput.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            idInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            parametersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            parametersInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            idLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            idInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            parametersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            parametersInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func addEvent() {
        guard let id = idInput.text, !id.isEmpty else { alert(message: "ID must be specified"); return }
        let json = parametersInput.text
        
        var event = Event(id: id)
        
        if json != nil && !json!.isEmpty {
            if let parameters = try? JSONDecoder().decode(ParameterSet.self, from: json!.data(using: .utf8)!) {
                event.parameters = parameters
            } else {
                alert(message: "Invalid JSON")
                return
            }
        }
        
        eventManager.capture(event, date: dateInput.date)
        dismiss(animated: true)
    }
    
    @objc func cancel() {
        dismiss(animated: true)
    }
    
    private func alert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

