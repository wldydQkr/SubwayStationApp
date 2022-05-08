//
//  StationDetailViewController.swift
//  Subway
//
//  Created by 박지용 on 2022/04/30.
//

import Alamofire
import UIKit
import SnapKit

final class StationDetailViewController: UIViewController {
    private let station: Station
    private var realtimeArrivalList: [StationArrivalDataResponseModel.RealTimeArrival] = []
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl() // 초기화 자체에서는 별도의 설정을 안해줘도됨
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        return refreshControl
    }()
    

    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.frame.width - 32.0, height: 100.0)
        
        layout.sectionInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        layout.scrollDirection = .vertical // 스크롤 방향
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(StationDeatilCollectionViewCell.self, forCellWithReuseIdentifier: "StationDetailViewController")
        
        collectionView.dataSource = self
        
        collectionView.refreshControl = refreshControl // collectionView는 기본적으로 refreshControl을 가지고 있지만 refreshControl은 옵셔널로 nil이기 때문에 동작할수 있도록 따로 정의해둔 refreshControl을 대입
        
        return collectionView
    }()
    
    init(station: Station) {
        self.station = station
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = station.stationName
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        fetchData()
    }
    
    @objc private func fetchData() {
        
        let stationName = station.stationName
        let urlString = "http://swopenapi.seoul.go.kr/api/subway/sample/json/realtimeStationArrival/0/5/\(stationName.replacingOccurrences(of: "역", with: ""))" // 역이라는 String값이 빈값이 됨
        
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "").responseDecodable(of: StationArrivalDataResponseModel.self) { [weak self] response in
            self?.refreshControl.endRefreshing()
            
            guard case .success(let data) = response.result else { return }
            
            self?.realtimeArrivalList = data.realtimeArrivalList
            self?.collectionView.reloadData()
        }
        .resume()
    }
}

extension StationDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realtimeArrivalList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationDetailViewController", for: indexPath) as? StationDeatilCollectionViewCell
        
        let realTimeArrival = realtimeArrivalList[indexPath.row]
        cell?.setup(with: realTimeArrival)
        
        return cell ?? UICollectionViewCell()
    }
}
