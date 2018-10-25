# Requirements Document
## 1 Introduction  
"GeoPlanner" is a location-based task manager for iOS. It will help you organize your plans by associating tasks with particular locations. The list of tasks will be divided by days and sorted by distance to the nearest associated place. Also the app will provide you with detailed information about nearest places connected to the task such as name, address and location on the map. It will help user choose the most suitable place and find it nearby. "GeoPlanner" will make completing your everyday tasks easier.

The app was built with Swift and is available on iOS 10.0 or higher.

## 2 User Requirements
### 2.1 Software Interfaces
The project interacts with Google Maps and Google Places API. Google Maps allows to add map which responses to user gestures and add markers of nearest places to the map. Google Places is used to get a list of nearest places of a particular type and get information about the place such as geographical coordinates, name, address and opening hours. Photos are uploaded using Alamofire.

### 2.2 User Interfaces
The GUI of the app was prototyped using mockups. 

![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/TasksList.png)

The main window shows the list of tasks sorted by date and minimum distance to places associated with tasks. To see detailed information about nearest places user have to tap on the table cell of the task. Then window with a list of nearest places and window with markers on the map will appear. It helps user get more information about nearest places, choose the most suitable one and find it by address or using map. 

![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/PlacesList.png)
![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/PlacesOnTheMap.png)

Window for adding a new task allows user to specify characteristics of the task and to choose whether to associate task with a particular kind of location or not.

![alt text](https://github.com/polinadulko/GeoPlanner/blob/master/Mockups/AddingNewTask.png)

### 2.3 User Characteristics
"GeoPlanner" would be useful for people who like to create to-do lists, plan their day and want to save their time by giving priority to some tasks based on the place they are at.
### 2.4 Assumptions and Dependencies
Without internet connection some features of the app won't be available. The app uses internet connection to get information about user's current location, nearest places for all of the tasks and to load the map. 
## 3 System Requirements
To run "GeoPlanner" on your device iOS 10.0 or higher is required.
### 3.1 Functional Requirements
The app will:
1. Display a list of tasks in a form of table with two columns  
1.1 First column will display tasks, second will display distance to nearest place associated with it
2. Divide tasks in the list by date
3. Sort tasks by minimum distance to the place
4. Provide managing tasks using gestures (swipe left to mark it as complete)
5. Show information about nearest places both in list and on the map  
5.1 Display info only about places that are open now  
5.2 Information in the list will contain name, address and distance to the place  
5.3 Marker on the map will contain only name of the place  
6. Functionate properly in case if internet connection is not available
7. Automatically update information connected with location when the device’s location changes significantly (300 meters)

The user will be able to:
1. Add a new task and specify it's details such as date and location  
1.1 Choose whether to connect task with a particular place or not  
1.2 Choose type of place or enter keyword associated with the place  
2. Enable automatic carry-over of the task day by day until it’s checked as done

### 3.2 Non-Functional Requirements
#### 3.2.1 Software quality attributes
1. Avoiding draining a device's battery  
Update data about user's location only when there has been a significant change in the device's location, for example 300 meters.
2. Flexible interface   
The app should support different screen sizes.
3. Security  
Explain a user how the app will use location data while getting a permission to access it and provide the security of the data.
#### 3.2.2 External interfaces
The app should have a user's permission to get current location using Core Location framework. Core Location uses GPS and Wi-Fi to gather information about the device's location. 
## 4.Analogues
1. [Reminders](https://itunes.apple.com/by/app/reminders/id1108187841?mt=8) is a default app for iOS that allows to create to-do lists and set reminders. That app can connect reminders to geographical coordinates. It allows user to choose the address where he wants to be reminded and choose whether he wants to get a reminder when he leaves or arrives at that location.
2. [gTasks](https://itunes.apple.com/by/app/gtasks/id428249408?mt=8) is a task manager which allows to set due dates for tasks, customize repeating tasks and set reminders. The user can set location-based reminders and get a reminder at a particular location.   

The main difference of GeoPlanner is that it associates a task with a place to sort tasks and show information about nearest places while analogues use location to send location-based reminders.
