# Requirements Document
## 1 Introduction  
"GeoPlanner" is a location-based task manager for iOS. It will help you organize your plans by associating tasks with particular locations. The list of tasks will be divided by days and sorted by distance to the nearest associated place. Also the app will provide you with detailed information about nearest places connected to the task such as name, address, location on the map and photos. It will help user choose the most suitable place and find it nearby. "GeoPlanner" will make completing your everyday tasks easier.

The app was built with Swift and is available on iOS 9.0 or higher.

## 2 User Requirements
### 2.1 Software Interfaces
The project interacts with Google Maps and Google Places API. Google Maps allows to add map which responses to user gestures and add markers of nearest places to the map. Google Places is used to get a list of nearest places of a particular type and get information about the place such as geographical coordinates, name, address, opening hours and photos. Photos are uploaded using Alamofire.

### 2.2 User Interfaces
The GUI of the app was prototyped using mockups. 

![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/TasksList.png)

The main window shows the list of tasks sorted by date and minimum distance to places associated with tasks. To see detailed information about nearest places user have to tap on the table cell of the task. Then window with a list of nearest places and window with markers on the map will appear. It helps user get more information about nearest places, choose the most suitable one and find it by address or using map. 

![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/PlacesList.png)
![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/PlacesOnTheMap.png)

Window for adding a new task allows user to specify characteristics of the task and to choose whether to associate task with a particular kind of location or not.

![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/AddingNewTask.png)

### 2.3 User Characteristics
### 2.4 Assumptions and Dependencies
Without internet connection some features of the app won't be available. The app uses internet connection to get information about user's current location, nearest places for all of the tasks and to load the map. 
## 3 System Requirements
To run "GeoPlanner" on your device iOS 9.0 or higher is required.
### 3.1 Functional Requirements
1. The app will display a list of tasks sorted by date (which should be indicated when creating a new task) and minimum distance to the place
2. The user will be able to add a new task and specify it's details such as date and location
3. The user will be able to enable automatic carry-over of the task day by day until it’s checked as done
4. The app will provide managing tasks using gestures (swipe left to mark it as complete, swipe right to delete it)
5. The system will show information about nearest places both in list and on the map.
6. Information about nearest places will be automatically updated when the device’s location changes significantly (at least 300 meters)
7. Provide proper functioning of the app in case if internet connection is not available
### 3.2 Non-Functional Requirements
#### 3.2.1 Software quality attributes
1. Avoiding draining a device's battery  
Most location-based apps are power-intensive because of permanent tracking of the user's location. One of the ways to organize getting data about user's location is to update it only when there is has been a significant change in the device's location, for example 300 meters.
2. Security  
It's important to explain a user how the app will use location data while getting a permission to access it and provide the security of the data.
## 4.Analogues
