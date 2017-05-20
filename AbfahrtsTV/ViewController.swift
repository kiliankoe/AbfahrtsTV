//
//  ViewController.swift
//  AbfahrtsTV
//
//  Created by Kilian Költzsch on 20.05.17.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import DVB

class ViewController: UIViewController {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var departureTable: UITableView!

    var stop = "Hauptbahnhof"
    var departures = [Departure]()

    override func viewDidLoad() {
        super.viewDidLoad()

        departureTable.dataSource = self
        departureTable.delegate = self

        refresh()
    }

    func refresh() {
        Departure.monitor(stopWithName: stop) { result in
            switch result {
            case .failure(_):
                break
            case .success(let response):
                self.stopButton.setTitle(response.stopName, for: .normal)
                self.departures = response.departures
                self.departureTable.reloadData()
            }
        }
    }

    @IBAction func onStopButtonTap() {
        let alert = UIAlertController(title: "Haltestelle", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Speichern", style: .default, handler: { _ in
            self.stop = (alert.textFields![0] as UITextField).text ?? ""
            DispatchQueue.main.async { self.refresh() }
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "DepartureCell")
        let departure = departures[indexPath.row]
        cell.textLabel?.text = "\(departure.line) \(departure.direction)"

        let detailText: String
        switch departure.actualEta {
        case 0:
            detailText = "Jetzt"
        case 1:
            detailText = "1 Minute"
        default:
            detailText = "\(departure.actualEta) Minuten"
        }

        cell.detailTextLabel?.text = detailText
        return cell
    }
}

extension ViewController: UITableViewDelegate {

}
