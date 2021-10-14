//
//  ContentView.swift
//  PTR
//


import SwiftUI
import CoreData

struct ContentView: View {
   
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CityEntity.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<CityEntity>

   @ObservedObject var monitor = NetworkMonitor()
    
    
    @State private var showingAlert = false
    @State private var lastUpdatedDate: Date?

    var body: some View {
        
        ZStack{
            
            NavigationView {
                
                if !items.isEmpty {
                    CityView()
                        .navigationTitle("Weather")
                        .toolbar{
                                ToolbarItem(placement: .automatic) {
                                    Button("Refresh") {
                                        fetchData()
                                    }
                                }
                            }
                      }
                else{
                    EmptyView()
                        .navigationTitle("Weather")
                }
            }
            
            .onAppear(perform: {
               fetchData()
            })

        }.alert(isPresented: $showingAlert) {
            Alert(title: Text(String("No Internet. Displaying offline data. Last updated at \(lastUpdatedDate!)")), message: Text("Please check the internet connection."), dismissButton: nil)
        }
       
    }
    
    
    //MARK: - API request 
    private func fetchData() {
        
        if(monitor.isConnected) {
         let networkManager = NetworkManager()
         networkManager.getWeather() { result, error in
             if error == nil{
                 processItems(arr: result!)
             }
             else if error == .noInternet {
                showingAlert = true
             } 
         }
    }
        else{
            print("Displaying data from DB")
            showingAlert = true
        }
    }
    
    //MARK: - Parsing JSON response 

    private func processItems(arr: [WeatherModel]) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var cityDictionary = [String : [[Date:Float]]]()
        debugPrint("Total counts \(arr.count)")
        for item in arr {
            let datetime = formatter.date(from: item.date)
            if let datetime = datetime {
                let valDict = [datetime : item.getCelsius()]
                cityDictionary[item.city.name, default: []].append(valDict)              
            }
        }
        
        let keys_sorted = cityDictionary.keys.sorted() //city names is sorted
        var arrDates = [Date]()
        
        for item in keys_sorted {
            if let arrValues = cityDictionary[item] {
                for keyVal in arrValues {
                    let dateStr = keyVal.first?.key
                    print("\(keyVal.keys)")
                    arrDates.append(dateStr!)
                }
            }
        }
        
        let eventsArr = Set(arrDates)
        let sortedArr = eventsArr.sorted()
        
        debugPrint("Array \(sortedArr)")
        deleteAllItems() //Replace the entire entity with latest value from json
        
        for item in keys_sorted {
            if let arrValues = cityDictionary[item] {
                let tupleArray: [(Date, Float)] = arrValues.flatMap { $0 }
                let dictonary_try = Dictionary(tupleArray, uniquingKeysWith: +) 

                debugPrint("dictionary \(dictonary_try)")
                
                //store it in core data
                addItems(dict: dictonary_try, item: item)
                lastUpdatedDate = Date()
            }
        }
    }
   
    
   
    // MARK: - CoreData - 
    ///Reset all entries of Entity
    private func deleteAllItems() {

        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
        try viewContext.executeAndMergeChanges(using: batchDeleteRequest)
        } catch {
            print ("There was an error")
        }
    }
    
    /// Add JSON response into Entity
    private func addItems(dict: [Date : Float], item: String) {
        withAnimation {
            
            let newItem = CityEntity(context: viewContext)
            newItem.name = item
            newItem.values = dict
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    } 
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Custom Views 

struct CityView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CityEntity.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<CityEntity>

    var body: some View {
        List {
        ForEach(items) { item in
            NavigationLink {
                List {
                    ForEach(item.values!.sorted(by: <), id: \.key) { key, value in
                             Section(header: Text("\(key)")) {
                                 Text(String(format: "%.2f ℃",value))
                             }
                         }
                     }
                .navigationTitle(item.name ?? "")
            } label: {
                Text(item.name ?? "")
                }
            }
        }
    }
}

struct EmptyView: View{
    
    var body: some View {
        Text("Check the network connection to fetch data from API ").font(.title)
    }
}



// MARK: - Extensions

extension NSManagedObjectContext {
  
    public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
