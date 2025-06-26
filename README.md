
## 📱 Screenshots

### Authentication Screens

| Login Screen | Signup Screen
|-----|-----
| 

 | 




### Main Application Screens

| Home Dashboard | Books List | Book Details
|-----|-----
| 

 | 

 | 




### Authors & Publishers

| Authors List | Author Details | Publishers List | Publisher Details
|-----|-----
| 

 | 

 | 

 | 




## 🚀 Features

### 🔐 Authentication System

- **User Registration**: Complete signup flow with form validation
- **Secure Login**: JWT token-based authentication
- **Session Management**: Automatic token storage and retrieval
- **Auto-login**: Remembers user sessions across app launches


### 🏠 Dashboard & Navigation

- **Welcome Interface**: Personalized greeting with modern design
- **Quick Actions**: Easy access to all major features
- **Latest News**: System updates and announcements
- **Server Information**: Direct links to API endpoints


### 📚 Books Management

- **Browse Books**: Complete book catalog with detailed information
- **Advanced Search**: Search by title, author, or publisher
- **Book Details**: Comprehensive book information including:

- Title, type, and price
- Author information with full biography
- Publisher details and location



- **Responsive Cards**: Modern card-based UI with book covers


### 👥 Authors Management

- **Author Directory**: Browse all authors with search capability
- **Author Profiles**: Detailed author information including:

- Full name and location details
- Complete address information
- List of published books



- **Author's Books**: View all books by a specific author


### 🏢 Publishers Management

- **Publisher Catalog**: Complete list of publishers
- **Publisher Profiles**: Detailed publisher information
- **Publisher's Books**: View all books from a specific publisher
- **Search Functionality**: Find publishers by name


## 🛠 Technical Architecture

### 📱 Frontend (Flutter)

```plaintext
lib/
├── main.dart                 # App entry point and configuration
├── models/                   # Data models
│   ├── user.dart            # User model with authentication data
│   └── book.dart            # Book, Author, Publisher models
├── services/                 # Business logic layer
│   ├── auth_service.dart    # Authentication state management
│   └── api_service.dart     # HTTP client and API integration
└── screens/                  # UI screens
    ├── splash_screen.dart   # Loading screen with app initialization
    ├── auth/                # Authentication screens
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── home/                # Main dashboard
    │   └── home_screen.dart
    ├── books/               # Book-related screens
    │   ├── books_screen.dart
    │   └── book_detail_screen.dart
    ├── authors/             # Author-related screens
    │   ├── authors_screen.dart
    │   └── author_detail_screen.dart
    └── publishers/          # Publisher-related screens
        ├── publishers_screen.dart
        └── publisher_detail_screen.dart
```

### 🔧 State Management

- **Provider Pattern**: Clean separation of UI and business logic
- **AuthService**: Manages user authentication state
- **API Service**: Handles all HTTP requests and data fetching


### 🌐 API Integration

The app integrates with a complete REST API with the following endpoints:

#### Authentication Endpoints

- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User authentication


#### Books Endpoints

- `GET /api/books` - Fetch all books
- `GET /api/books/:id` - Get specific book details
- `GET /api/books/search/:query` - Search books by title
- `POST /api/books` - Add new book (Admin only)


#### Authors Endpoints

- `GET /api/authors` - Fetch all authors
- `GET /api/authors?q=query` - Search authors by name
- `GET /api/authors/:id/books` - Get author with their books
- `POST /api/authors` - Add new author (Admin only)


#### Publishers Endpoints

- `GET /api/publishers` - Fetch all publishers
- `GET /api/publishers?q=query` - Search publishers by name
- `GET /api/publishers/:id/books` - Get publisher with their books
- `POST /api/publishers` - Add new publisher (Admin only)


## 🎨 UI/UX Design

### Design Principles

- **Material Design**: Following Google's Material Design guidelines
- **Color Coding**: Different colors for different sections:

- 🔵 Blue: Books and general navigation
- 🟢 Green: Authors
- 🟣 Purple: Publishers
- 🟠 Orange: Search and notifications





### User Experience Features

- **Loading States**: Proper loading indicators for all async operations
- **Empty States**: Informative empty state screens with helpful messages
- **Error Handling**: User-friendly error messages with retry options
- **Pull-to-Refresh**: Refresh functionality on all list screens
- **Search as You Type**: Real-time search with debouncing
- **Responsive Design**: Optimized for different screen sizes


## 📋 Prerequisites

Before running this project, ensure you have:

### Development Environment

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control


### For Android Development

- **Android SDK**
- **Android Emulator** or physical Android device
- **Java Development Kit (JDK)**


### For iOS Development (Mac only)

- **Xcode** (latest version)
- **iOS Simulator** or physical iOS device
- **CocoaPods**


### Backend Requirements

- **Node.js** server running on port 34723
- **MongoDB** database
- **REST API** endpoints as described above


## 🚀 Installation & Setup

### 1. Clone the Repository

```shellscript
git clone <repository-url>
cd book-management-flutter-app
```

### 2. Install Flutter Dependencies

```shellscript
flutter pub get
```

### 3. Configure API Connection

Update the API base URL in `lib/services/api_service.dart`:

```plaintext
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:34723/api';

// For iOS Simulator
static const String baseUrl = 'http://localhost:34723/api';

// For Physical Device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.XXX:34723/api';
```

### 4. Setup Backend Server

Ensure your Node.js server is running:

```shellscript
# In your server directory
npm install
node server.js
```

### 5. Run the Application

```shellscript
# List available devices
flutter devices

# Run the app
flutter run

# For release build
flutter run --release
```

## 📱 How We Built Each Screen

### 1. Splash Screen (`splash_screen.dart`)

**Purpose**: App initialization and authentication check

**Implementation**:

- Displays app logo and loading indicator
- Checks for stored authentication token
- Automatically navigates to appropriate screen (Login or Home)
- Uses `Future.delayed()` for smooth transition


**Key Features**:

- Gradient background with app branding
- Automatic token validation
- Smooth navigation transitions


### 2. Authentication Screens

#### Login Screen (`login_screen.dart`)

**Purpose**: User authentication interface

**Implementation**:

- Form validation for username and password
- JWT token handling and storage
- Error handling with user feedback
- Navigation to signup screen


**Key Features**:

- Clean, modern UI with gradient background
- Form validation with error messages
- Loading states during authentication
- "Remember me" functionality through token storage


#### Signup Screen (`signup_screen.dart`)

**Purpose**: New user registration

**Implementation**:

- Multi-field form with validation
- API integration for user creation
- Success feedback and navigation
- Password strength validation


**Key Features**:

- Comprehensive form validation
- Real-time input validation
- Success/error feedback
- Automatic navigation after successful signup


### 3. Home Dashboard (`home_screen.dart`)

**Purpose**: Main navigation hub and app overview

**Implementation**:

- Grid-based quick actions layout
- Latest news section with announcements
- Server information display
- Logout functionality


**Key Features**:

- Gradient welcome section
- Color-coded action cards
- Server endpoint information
- Quick access to all major features


### 4. Books Management

#### Books List Screen (`books_screen.dart`)

**Purpose**: Browse and search books catalog

**Implementation**:

- ListView with custom card design
- Real-time search functionality
- Pull-to-refresh capability
- Navigation to book details


**Key Features**:

- Search bar with instant filtering
- Book cards with cover placeholders
- Price and category display
- Author and publisher information


#### Book Detail Screen (`book_detail_screen.dart`)

**Purpose**: Detailed book information display

**Implementation**:

- Comprehensive book information layout
- Author and publisher details integration
- Responsive design for different screen sizes
- Professional card-based information display


**Key Features**:

- Large book cover placeholder
- Detailed information cards
- Author and publisher profiles
- Price and category highlighting


### 5. Authors Management

#### Authors List Screen (`authors_screen.dart`)

**Purpose**: Browse and search authors directory

**Implementation**:

- API-integrated search functionality
- Author cards with location information
- Navigation to author details
- Real-time search with API calls


**Key Features**:

- Server-side search integration
- Location-based author information
- Professional author cards
- Search history and suggestions


#### Author Detail Screen (`author_detail_screen.dart`)

**Purpose**: Detailed author profile and their books

**Implementation**:

- Author information display
- Integration with books API
- List of author's published books
- Navigation to individual book details


**Key Features**:

- Author profile with avatar
- Complete biographical information
- Books by author section
- Book count display


### 6. Publishers Management

#### Publishers List Screen (`publishers_screen.dart`)

**Purpose**: Browse and search publishers catalog

**Implementation**:

- Similar structure to authors screen
- Publisher-specific search functionality
- Location-based information display
- Navigation to publisher details


**Key Features**:

- Publisher cards with business information
- Location-based search
- Professional business-style design
- Search functionality


#### Publisher Detail Screen (`publisher_detail_screen.dart`)

**Purpose**: Detailed publisher information and their books

**Implementation**:

- Publisher profile display
- Books catalog integration
- Business information layout
- Navigation to published books


**Key Features**:

- Business profile design
- Published books section
- Location and contact information
- Book catalog integration


## 🔧 Key Implementation Details

### State Management with Provider

```plaintext
// AuthService manages authentication state
class AuthService extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  
  // Getters for state access
  bool get isAuthenticated => _token != null;
  
  // Methods for state updates
  Future<void> saveToken(String token) async {
    // Token storage and state update
  }
}
```

### API Service Architecture

```plaintext
class ApiService {
  static const String baseUrl = 'http://localhost:34723/api';
  
  // Generic HTTP methods
  Map<String, String> _getHeaders({String? token}) {
    // Header configuration with optional authentication
  }
  
  // Specific API methods
  Future<List<Book>> getBooks() async {
    // Books API integration
  }
}
```

### Error Handling Strategy

- **Network Errors**: Graceful handling with user-friendly messages
- **Authentication Errors**: Automatic logout and redirect to login
- **Validation Errors**: Real-time form validation feedback
- **Server Errors**: Retry mechanisms and error reporting


### Performance Optimizations

- **Lazy Loading**: Images and data loaded on demand
- **Caching**: Token and user data cached locally
- **Debouncing**: Search queries debounced to reduce API calls
- **Memory Management**: Proper disposal of controllers and listeners


## 🧪 Testing

### Manual Testing Checklist

- User registration and login flow
- Token persistence across app restarts
- Books browsing and search functionality
- Authors directory and search
- Publishers catalog and search
- Navigation between all screens
- Error handling for network issues
- Responsive design on different screen sizes


### Test Data Setup

Create test data using your API:

```shellscript
# Create test user
curl -X POST http://localhost:34723/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123", "firstName": "Test", "lastName": "User"}'
```

## 🚀 Deployment

### Android Deployment

```shellscript
# Build APK for testing
flutter build apk

# Build App Bundle for Play Store
flutter build appbundle
```

### iOS Deployment (Mac only)

```shellscript
# Build for iOS
flutter build ios

# Archive for App Store
# Use Xcode for final submission
```

## 🔮 Future Enhancements

### Planned Features

- **Admin Panel**: Full CRUD operations for books, authors, and publishers
- **Offline Support**: Local database caching with SQLite
- **Push Notifications**: Real-time updates for new books
- **Book Reviews**: User rating and review system
- **Favorites**: Bookmark favorite books and authors
- **Dark Mode**: Theme switching capability
- **Advanced Search**: Filters by genre, price range, publication date
- **Social Features**: Share books and recommendations