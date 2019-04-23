

import UIKit
import FirebaseCore
import FirebaseFirestore
import SDWebImage

class TableViewController: UITableViewController {

    private var documents: [DocumentSnapshot] = []
    public var dealerships: [Dealership] = []
    private var listener : ListenerRegistration!
    var selectedDealership: Dealership? = nil
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("dealerships").limit(to: 50)
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.query = baseQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.dealerships = []
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            for snap in snapshot.documents {
             
                let dealership = Dealership(name: snap.data()["name"] as! String, location: snap.data()["location"] as! String, opening_times: snap.data()["opening_times"] as! String, image_url: snap.data()["image_url"] as! String, maps_link: snap.data()["maps_link"] as! String, phone: snap.data()["phone"] as! String, id: snap.data()["name"] as! String)
                self.dealerships.append(dealership)
                }
            
            
            //self.dealerships = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealerships.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        cell.lblName.text = dealerships[indexPath.row].name
        cell.lblPhone.text = "Opens from: \(dealerships[indexPath.row].phone)"
        cell.ivImage.sd_setImage(with: Foundation.URL(string: dealerships[indexPath.row].image_url), placeholderImage: #imageLiteral(resourceName: "placeholder"))
    

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DealershipDetailsViewController
        if let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            vc.dealership = self.dealerships[indexPath.row]
            
        }
    }


}

