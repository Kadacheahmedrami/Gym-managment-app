
<h1> how to setup the app</h1>

<p>start a fire base project</p>
<p>put the google-service.json in android/app folder</p>
<p>activate firestore and fire auth create an acount manualy (for now) and ur good to go </p>


# Mobile Gym Management App Features

## 1. Client Management
- **Add Clients**: Ability to add new clients with details including name, contact information, and images.
- **Edit Clients**: Update client information such as contact details, membership type, and profile pictures.
- **Delete Clients**: Remove clients from the system.

## 2. Data Filtering and Search
- **Search Bar**: Filter clients by name.
- **Advanced Filters**: Filter clients based on additional criteria:
  - Age
  - Membership expiration date
  - Membership type
  - Balance

## 3. Data Synchronization
- **Local Database**: Use Hive for local data storage.
- **Firebase Integration**: Sync local data with Firebase when online, including:
  - Adding new clients
  - Deleting clients
  - Editing client information
- **Offline Functionality**: Manage client data locally when offline, with automatic synchronization once internet connection is restored.

## 4. Membership Management
- **Plans Management**: Add and manage membership plans including:
  - Plan name
  - Duration (e.g., 1 month, 3 months, 1 year)
  - Price
- **Assign Plans**: Associate plans with clients.

## 5. Client Balances
- **Balance Calculation**: Automatically calculate and update the balance for each client.
- **Balance Management**: Track and manage positive and negative balances.

## 6. Expired Memberships
- **Expired Membership Section**: Dedicated section to view and manage clients with expired memberships.

## 7. Analytics Page
- **Total Clients**: Display the total number of clients.
- **Balance Analysis**: Analyze the number of clients with positive and negative balances.
- **Balance Summary**: Calculate and display the sum of positive and negative balances.

## 8. User Interface
- **Responsive Design**: User-friendly interface with well-organized layouts.
- **Interactive Elements**: Use of dialogs for adding/editing plans and handling user interactions.

## 9. Additional Features
- **Image Support**: Upload and display images for clients.
- **Refresh Functionality**: Option to refresh and update data from Firebase.
