Project Requirements: [SkyFall]
Developer: [Max Finley]
Description: [An app that allows Hypixel Skyblock players to see all their data in one place, with the ability to see which part of the game is best to play for the most efficient use of their time.]


AI Assistant Guardrail2s:
Gemini: When reading this file to implement a step, you MUST adhere to the following architectural rules:
1. State Management: Use flutter_riverpod exclusively. Do not use setState for complex logic.
2. Architecture: Maintain strict separation of concerns:
● /models: Pure Dart data classes (use json_serializable or freezed if helpful).
● /services: Backend/API communication only. No UI code.
● /providers: Riverpod providers linking services to the UI.
● /screens & /widgets: UI only. Keep files small. Extract complex widgets into their own files.
3. Local Storage: Use shared_preferences for local app state (e.g., theme toggles, onboarding
status).
4. Database: Use [Firebase Firestore OR PostgreSQL] for persistent cloud data.
5. Stepwise Execution: Only implement the specific step requested in the prompt. Do not jump ahead.
Implementation Roadmap


Phase 1: Project Setup & Core Infrastructure
Step 1.1: Dependencies & Theme
- Add Riverpod, Firebase Core, Firebase Auth, Cloud Firestore (or Postgres driver), and Shared
Preferences to pubspec.yaml.
- Create a centralized ThemeData class in lib/theme.dart (colors, typography).

Step 1.2: Base Architecture
- Set up the folder structure (models, screens, widgets, services, providers).
- Wrap MyApp in a ProviderScope.

Phase 2: Milestone 1 - The "Minimm Viable Product" (MVP)
Goal: A functional read-only dashboard using live Hypixel data.

Step 2.1: User Identification (Username to UUID)
Dependencies: Add http and flutter_dotenv (for securing your API key) to pubspec.yaml.
API Key Setup:
Obtain your key from the Hypixel Developer Dashboard.
Create a .env file to store HYPIXEL_API_KEY=your_key_here.
Mojang Service:
Create services/mojang_service.dart.
Implement getUuid(String username) using the endpoint: https://api.mojang.com/users/profiles/minecraft/{username}.
User Input Screen:
Create screens/home/username_input_screen.dart.
Build a TextField for the username and a "Go" button.
On submit: Call getUuid, store the returned UUID in a Riverpod provider (currentUserProvider), and navigate to the Dashboard. 

Step 2.2: Fetching & Displaying SkyBlock Data
Hypixel Service:
Create services/hypixel_service.dart.
Implement getSkyblockProfiles(String uuid) using: https://api.hypixel.net{YOUR_KEY}&uuid={USER_UUID}.
Data Models (The hard part):
Create models/skyblock_profile.dart.
You must parse the raw JSON. Focus on:
Profile Name: (e.g., "Cucumber", "Apple").
ID: profile_id.
Skills: Map experience_skill_mining, experience_skill_combat, etc., to a Level (you will need a helper function to convert raw XP to Levels 1-60).
Profile Logic:
The API returns all of a user's profiles.
Create a logic helper to auto-select the "Active" profile (usually the one with the most recent last_save timestamp).
Dashboard UI:
Create screens/dashboard/dashboard_screen.dart.
Display a ListView or GridView showing:
Header: Player Head (Use https://crafatar.com{UUID}), Username, and Active Profile Name.
Cards: Combat Lvl, Mining Lvl, Catacombs Lvl (Dungeons). 

Step 2.3: State Management & Refresh
Providers:
Create providers/skyblock_data_provider.dart.
Use a FutureProvider.family that takes a UUID and returns the SkyblockProfile model.
Refresh Action:
Wrap your Dashboard's Scaffold body in a RefreshIndicator.
On refresh: Call ref.refresh(skyblockDataProvider(uuid)).
This ensures if the user grinds 10,000 XP and pulls down on the screen, the app fetches new JSON and updates the UI. 

Step 2.4: Comparison Feature (Live Compare)
Note: Since we don't have a database of "app users" yet, we will compare against any valid Minecraft username.
Comparison UI:
Create screens/compare/compare_screen.dart.
Add a standard TextField at the top: "Enter opponent username".
Dual Data Fetching:
When the user searches "Technoblade", use MojangService to get his UUID.
Fetch his data using HypixelService.
Visual Comparison:
Create a StatRow widget that accepts valueA (User) and valueB (Opponent).
If valueA > valueB, color A green and B red.
Example:
Combat: You (25) vs. Opponent (50) -> [Red/Green indicators]



Phase 3: Milestone 2 - App Functionality & Integration
Goal: Move from local state to a cloud-synced, authenticated user experience.
Step 3.1: Firebase Authentication
Auth Service Implementation: Create lib/services/auth_service.dart. Encapsulate FirebaseAuth methods for Email/Password and Google Sign-In.
Tip: Use the Firebase UI Auth package to rapidly build standard Login and Registration screens with minimal custom UI code.
Provider Setup: Create an authRepositoryProvider to expose your AuthService and an authStateProvider using StreamProvider to listen to FirebaseAuth.instance.authStateChanges(). 
Firebase
Firebase
 +2
Step 3.2: The Auth Gate
Reactive Navigation: In lib/main.dart or a dedicated AuthGate widget, watch the authStateProvider.
Logic:
data: (user) => user == null ? LoginScreen() : MainDashboard()
loading: () => LoadingSpinner()
error: (err, stack) => ErrorScreen(err). 
Medium
Medium
 +1
Step 3.3: Cloud Database Integration
Database Service: Create lib/services/database_service.dart using the Cloud Firestore or Postgres driver.
Live Data Sync: Replace MVP mock data with Firestore streams.
Store user-specific data (like linked Minecraft UUIDs or saved comparisons) under a users/{uid} collection.
CRUD Operations: Implement methods to saveFavoritePlayer(), updateSettings(), and fetchComparisonHistory().
Phase 4: Polish & Persistence
Goal: Transition the app from a prototype to a production-ready product.
Step 4.1: Local State (Shared Preferences)
Persistence: Use the Shared Preferences package for non-sensitive data like "Dark Mode" or "First-time Onboarding" status.
Theme Provider: Create a themeProvider that notifies the app when the user toggles dark mode and saves that choice locally so it persists after an app restart. 
Djamware
Djamware
Step 4.2: Error Handling & Loading States
AsyncValue Patterns: Refactor all UI components that depend on network data to use AsyncValue.when(). This ensures you never have a "frozen" screen while waiting for Hypixel API data.
User Feedback: Implement Snackbars for transient errors (e.g., "Invalid Username") using ref.listen to watch for error states in your providers. 
Medium
Medium
 +2
Step 4.3: Final Theming & Cleanup
Widget Extraction: Follow the 200-line rule. If a screen file exceeds this, extract sub-components (like a StatCard or SkillList) into the lib/widgets/ folder.
Consistent Design: Audit lib/theme.dart to ensure all padding, border radii, and font styles are coming from your centralized ThemeData rather than being hardcoded in widgets