import UIKit
import CoreLocation


class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
        
    @IBOutlet weak var weatherCondition: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displaySampleImageForDemo()
        locationManager.delegate = self
        searchTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.endEditing(true)
            loadWeather(search: searchTextField.text)
            return true
        }
    
    private func displaySampleImageForDemo(){
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemCyan, .systemBrown, .systemMint
        ])
        
        weatherConditionImage.preferredSymbolConfiguration = config
        
        weatherConditionImage.image = UIImage(systemName: "sun.max.fill")
    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                if let location = locations.last{
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    
                    guard let url=getURL(query: "\(latitude), \(longitude)") else{
                        return
                    }

                    let session=URLSession.shared
                    
                    let dataTask=session.dataTask(with: url) { data, response, error in
                        
                        guard error == nil else{
                            return
                        }
                        
                        guard let data = data else {
                            return
                        }
                        
                        if let weatherData=self.parseJson(data: data){
                            
                            
                            DispatchQueue.main.async { [self] in
                                self.locationLabel.text = weatherData.location.name
                                self.temperatureLabel.text = "\(weatherData.current.temp_c)C"
                                self.weatherCondition.text = "\(weatherData.current.condition.text)"
                                let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue,.systemGreen,.systemYellow])

                                self.weatherConditionImage.preferredSymbolConfiguration = config
                                
                                
                                if(weatherData.current.condition.code == 1000){
                                    self.weatherConditionImage.image=UIImage(systemName:"sun.max")
                                } else if (weatherData.current.condition.code == 1009){
                                    self.weatherConditionImage.image=UIImage(systemName:"cloud.fill")
                                } else if (weatherData.current.condition.code == 1087){
                                    self.weatherConditionImage.image=UIImage(systemName:"cloud.heavyrain.fill")
                                } else if(weatherData.current.condition.code == 1171){
                                    self.weatherConditionImage.image = UIImage(systemName: "cloud.sleet.fill")
                                } else if(weatherData.current.condition.code == 1225){
                                    self.weatherConditionImage.image = UIImage(systemName: "snowflake.fill")
                                } else{
                                    self.weatherConditionImage.image = UIImage(systemName: "cloud.moon.rain")
                                }
                            }
                        }
                    }
                    
                    dataTask.resume()
                }
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    private func loadWeather(search: String?){
        guard let search = search else {
            return
        }
        guard let url = getURL(query: search) else {
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            if let weatherData = self.parseJson(data: data){
              
                
                DispatchQueue.main.async { [self] in
                    self.locationLabel.text=weatherData.location.name
                    self.temperatureLabel.text="\(weatherData.current.temp_c)C"
                    self.weatherCondition.text="\(weatherData.current.condition.text)"
                    let config = UIImage.SymbolConfiguration(paletteColors:  [.systemCyan, .systemBrown, .systemMint    ])

                    
                    if(weatherData.current.condition.code == 1000){
                        self.weatherConditionImage.image=UIImage(systemName:"sun.max")
                    } else if (weatherData.current.condition.code == 1009){
                        self.weatherConditionImage.image=UIImage(systemName:"cloud.fill")
                    } else if (weatherData.current.condition.code == 1087){
                        self.weatherConditionImage.image=UIImage(systemName:"cloud.heavyrain.fill")
                    } else if(weatherData.current.condition.code == 1171){
                        self.weatherConditionImage.image = UIImage(systemName: "cloud.sleet.fill")
                    } else if(weatherData.current.condition.code == 1225){
                        self.weatherConditionImage.image = UIImage(systemName: "snowflake.fill")
                    } else{
                        self.weatherConditionImage.image = UIImage(systemName: "cloud.moon.rain")
                    }
                    
                   
   
                }
            }
        }
        
        dataTask.resume()
    }
    private func getURL(query: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "7366506185ae4f6da6733021220308"
        guard let url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url )
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error")
        }
        return weather
    }
}

struct WeatherResponse: Decodable{
    let location: Location
    let current: Weather
}

struct Location: Decodable{
    let name: String
}

struct Weather: Decodable{
    let temp_c : Float
    let condition : WeatherCondition
}

struct WeatherCondition: Decodable{
    let text: String
    let code: Int
}



