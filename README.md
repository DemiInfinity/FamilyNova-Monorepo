# FamilyNova

A safe social networking platform designed for children to learn, connect with friends, and develop healthy online social etiquette in a protected environment.

## 🎯 Mission

FamilyNova aims to provide a secure, educational social media experience for kids while protecting them from the toxicity and hate commonly found on mainstream social media platforms. We believe children should learn how to navigate online social interactions in a safe, supervised environment that promotes positive communication and digital citizenship.

## ✨ Key Features

### For Kids
- **Safe Social Networking**: Connect and communicate with verified friends in a protected environment
- **Educational Content**: Learn about online safety, digital citizenship, and proper social media etiquette
- **Positive Community**: Experience social media without exposure to hate, cyberbullying, or inappropriate content
- **Verified Friends Only**: Interact only with other verified children, ensuring a safe peer group

### Two-Tick Verification System
- **Parent Verification**: First verification tick - Parents must verify their child's identity
- **School Verification**: Second verification tick - Schools confirm the child's enrollment and identity
- **Identity Assurance**: This dual verification system ensures that every child on the platform is who they claim to be, creating a trusted community

### For Parents
- **Automatic Parent Connections**: Parents are automatically connected with other parents whose children are friends with their kids
- **Parent-to-Parent Communication**: Direct communication channels between parents to discuss their children's friendships and activities
- **Real-Time Monitoring**: Monitor your child's interactions, messages, and social connections in real-time
- **Moderation Tools**: Parents act as moderators of their children's online experience, with tools to review and manage interactions
- **Activity Insights**: Get insights into your child's social activity, friend connections, and online behavior

### Safety & Moderation
- **Parent-Led Moderation**: Parents have full visibility and control over their children's online interactions
- **Content Filtering**: Advanced filtering to prevent inappropriate content and harmful interactions
- **Safe Environment**: Zero tolerance for bullying, hate speech, or inappropriate behavior
- **Educational Guidance**: Built-in resources to teach children about responsible online behavior

## 🏗️ Monorepo Structure

FamilyNova is organized as a monorepo containing multiple applications and shared packages:

```
familynova/
├── backend/               # Node.js/Express API server (✅ Complete)
├── apps/
│   ├── android-kids/      # Android app for children (✅ UI Complete)
│   ├── android-parent/    # Android app for parents (✅ UI Complete)
│   ├── ios-kids/         # iOS app for children (📋 Structure Ready)
│   ├── ios-parent/       # iOS app for parents (📋 Structure Ready)
│   └── web/              # Next.js web application (✅ Basic UI Complete)
├── packages/
│   └── shared/           # Shared design system and utilities (✅ Design System)
└── README.md
```

### Applications

- **Android Kids App** (`apps/android-kids/`): Native Android application for children
- **Android Parent App** (`apps/android-parent/`): Native Android application for parents
- **iOS Kids App** (`apps/ios-kids/`): Native iOS application for children
- **iOS Parent App** (`apps/ios-parent/`): Native iOS application for parents
- **Web Application** (`apps/web/`): Web application that unifies all platforms

### Shared Packages

- **Shared** (`packages/shared/`): Common code, types, business logic, and utilities used across all applications

## 🏗️ Project Status

This project is currently in early development. The monorepo structure has been established with:

### ✅ Completed
- **Backend API**: Complete Node.js/Express REST API with authentication, user management, messaging, and verification systems
- **Android Kids App**: Full UI implementation with Login, Home, Friends, Messages, and Profile screens
- **Android Parent App**: Full UI implementation with Dashboard, Monitoring, Connections, and Settings screens
- **Web Application**: Next.js app with landing page, kids portal, and parents portal
- **Design System**: Shared color palette and design guidelines for consistent UI across platforms
- **Monorepo Structure**: Complete directory organization for all platforms

### 🚧 In Progress / Planned
- iOS apps development (SwiftUI implementation)
- API integration for all mobile apps
- Real-time messaging features
- Advanced moderation tools
- School verification system integration
- Shared TypeScript/JavaScript packages for business logic

## 🛠️ Technology Stack

### Android Apps
- **Platform**: Android (Native)
- **Language**: Java
- **Minimum SDK**: 24 (Android 7.0)
- **Target SDK**: 35 (Latest Android)
- **Build System**: Gradle 8.9
- **Architecture**: To be determined

### iOS Apps
- **Platform**: iOS (Native)
- **Language**: Swift (planned)
- **Minimum iOS Version**: TBD
- **Architecture**: To be determined

### Web Application
- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Architecture**: App Router (Next.js 14)

### Backend API
- **Framework**: Express.js
- **Language**: JavaScript (Node.js)
- **Database**: MongoDB (Mongoose)
- **Authentication**: JWT
- **Security**: Helmet, CORS, bcrypt

### Shared Code
- **Design System**: Markdown documentation with color palettes and guidelines
- **Future**: TypeScript/JavaScript packages for cross-platform business logic

## 📋 Planned Features

- [ ] User authentication system (separate for kids and parents)
- [ ] Two-tick verification system (parent + school)
- [ ] Friend connection system
- [ ] Parent-to-parent automatic connection
- [ ] Real-time messaging with moderation
- [ ] Content filtering and safety features
- [ ] Parent dashboard and monitoring tools
- [ ] Educational content and resources
- [ ] School verification integration
- [ ] Privacy controls and settings

## 🔒 Privacy & Safety

FamilyNova is built with child safety and privacy as the top priority:
- All accounts require dual verification
- Parents have full visibility into their children's activities
- No data is shared with third parties
- COPPA compliant (Children's Online Privacy Protection Act)
- Secure communication channels
- Regular safety audits and updates

## 👥 Target Audience

- **Primary**: Children aged 8-16 seeking a safe social media experience
- **Secondary**: Parents who want to actively monitor and guide their children's online interactions
- **Tertiary**: Schools interested in teaching digital citizenship and online safety

## 🤝 Contributing

This project is in early development. Contributions and feedback are welcome as we build a safer social media experience for children.

## 📄 License

[License to be determined]

## 📧 Contact

For questions, suggestions, or partnerships, please reach out through the project repository.

---

**Note**: FamilyNova is designed to be a positive alternative to mainstream social media, where children can learn and grow in a safe, supervised environment. We believe that with proper guidance and moderation, children can develop healthy online social skills that will serve them throughout their lives.

