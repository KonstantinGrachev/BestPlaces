import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    //MARK: - constants

    enum Constants {
        static let heightForRow: CGFloat = 85
    }
    
    //MARK: - UI objects

    private let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = MainConstants.sideIndentation
        tableView.separatorInset.right = MainConstants.sideIndentation
        tableView.backgroundColor = .secondarySystemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
//    private var places = PlaceModel.generatePlaces()
    
    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setDelegates()
        setConstraints()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    private func setupViews() {
        navigationItem.title = "Best Places"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        view.addSubview(placesTableView)
    }
    
    private func setDelegates() {
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.placeCellId)
    }
    
    //MARK: - @IBActions

    @IBAction private func addButtonTapped() {
        let addPlaceController = AddViewController()
        addPlaceController.delegate = self
        navigationController?.pushViewController(addPlaceController, animated: true)
    }
}

//MARK: - table view


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        places.count
        0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = placesTableView.dequeueReusableCell(withIdentifier: PlaceCell.placeCellId, for: indexPath) as? PlaceCell else { return UITableViewCell() }
//        cell.configure(model: places[indexPath.row])
        return cell
    }
}

//MARK: - constraints

extension ViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            placesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            placesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - delegate AddViewController

extension ViewController: AddViewControllerDelegate {
    func addNewPlaceInModel(newPlace: PlaceModel?) {
        guard let newPlace = newPlace else {
            return
        }
//        places.append(newPlace)
        placesTableView.reloadData()
    }
}
