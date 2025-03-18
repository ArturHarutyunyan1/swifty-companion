# Swifty Companion

![](./media/video.gif)

## Description
Swifty Companion is an iOS application built with SwiftUI that allows users to search for and view profile information of individuals based on their login credentials. The app provides detailed information, including login, skills, completed and failed projects, and more. The user interface is designed with modern layout techniques to ensure proper display across various screen sizes.

## Features
- **Search Functionality**: Users can enter a login to retrieve profile details.
- **User Information Display**:
    - Login
    - Level
    - Location
    - Wallet
    - Evaluations
    - Profile Picture
- **Skills Section**: Displays the user’s skills along with level and percentage.
- **Projects Section**: Lists all completed and failed projects.
- **Navigation**: Users can navigate back to the search screen easily.
- **Responsive UI**: Uses SwiftUI layout techniques to ensure compatibility across different screen sizes.

## Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo/user-profile-viewer.git
   ```
2. Open the project in Xcode:
   ```sh
   cd swifty-companion
   open swifty-companion.xcodeproj
   ```
3. Build and run the application:
    - Select an iOS Simulator or a connected device.
    - Click on the **Run** button in Xcode.

## Usage
1. Create new application in 42 Intra page
2. Create Config.plist file, and put credentials from API there (see Config.example file)
3. Open the application.
4. Enter a login to search for a user profile.
5. View the user details, including skills and projects.
6. Navigate back to the main screen if needed.
