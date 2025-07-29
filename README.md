<p align="center">
  <img src="https://github.com/sketchide/SketchIDE/blob/master/android/app/src/main/ic_launcher-playstore.png" width="120">
</p>

# 🎨 SketchIDE

<p align="center">
  <img src="https://img.shields.io/badge/Status-Prototype-orange" alt="Prototype Status">
  <img src="https://img.shields.io/badge/Version-Development-blue" alt="Development Version">
  <a href="https://t.me/sketchidegroup">
    <img src="https://img.shields.io/badge/Telegram-Group-blue?logo=telegram" alt="Telegram Group">
  </a>
  <a href="https://t.me/sketchide">
    <img src="https://img.shields.io/badge/Telegram-Channel-blue?logo=telegram" alt="Telegram Channel">
  </a>
  <img src="https://img.shields.io/github/contributors/sketchide/SketchIDE" alt="GitHub Contributors">
  <img src="https://img.shields.io/github/last-commit/sketchide/SketchIDE" alt="GitHub Last Commit">
</p>

> ⚠️ **PROTOTYPE STATUS**: SketchIDE is currently in active development as a prototype. This is not a production release and is intended for testing, feedback, and development purposes only.

**SketchIDE** is a visual mobile IDE that enables anyone to build **native Android & iOS applications** through an intuitive drag-and-drop interface. Built with **Flutter** for modern cross-platform development, SketchIDE makes app creation accessible without requiring coding knowledge.

---

## ✨ Core Capabilities

```mermaid
mindmap
  root((SketchIDE))
    Visual Design
      Drag & Drop UI Builder
      Material 3 Widgets
      Real-time Preview
      Fixed Device Frame
    Property Management
      Color-coded Properties
      Smart Property Editor
      Sequential Widget IDs
      Auto-validation
    Code Generation
      Flutter Code Output
      Real-time Updates
      Project Management
      Export Support
    Touch System
      Native Touch Handling
      Gesture Recognition
      Multi-touch Support
      Selection System
```

### 🎯 **Visual Editor Features**
- **Intuitive Drag & Drop Interface** with smooth animations
- **Fixed Mobile Device Frame** (360x640dp) for consistent design
- **Property Panel** with slide-up animation and visual feedback
- **Smart Widget Management** with auto-selection and validation
- **Real-time Visual Feedback** during design operations

### 🔧 **Development Features**
- **Live Flutter Code Generation** from visual components
- **Sequential Widget Naming** (text1, text2, text3, etc.)
- **Project File Management** with organized structure
- **Cross-platform Output** supporting Android and iOS
- **Offline Development** with local project storage

### 🎨 **Property System**
- **Color-coded Property Types**: Text (Blue), Size (Green), Color (Purple), Number (Orange)
- **Smart Property Validation** with real-time error feedback
- **Comprehensive Widget Properties** for complete customization
- **Visual Property Editor** with intuitive controls

---

## 🚀 Current Development Status

<table>
<tr>
<td width="50%">

### ✅ **Implemented Features**
- [x] Visual drag & drop UI builder
- [x] Mobile device frame (360x640dp)
- [x] Property panel with animations
- [x] Touch controller system
- [x] Widget validation service
- [x] Flutter code generation
- [x] Project management
- [x] Frame widget system
- [x] Selection and feedback system

</td>
<td width="50%">

### 🔄 **In Development**
- [ ] Block-based logic editor
- [ ] Advanced widget templates
- [ ] Cloud build integration
- [ ] Plugin system
- [ ] Import/Export functionality
- [ ] Advanced animations
- [ ] Custom component library
- [ ] Multi-screen support

</td>
</tr>
</table>

---

## 📱 App Development Workflow

```mermaid
graph LR
    A[📱 Create Project] --> B[🎨 Design UI]
    B --> C[⚙️ Configure Properties]
    C --> D[🔧 Add Logic]
    D --> E[👀 Preview App]
    E --> F[📦 Export Project]
    F --> G[🏗️ Build App]
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fce4ec
    style F fill:#e0f2f1
    style G fill:#f1f8e9
```

### Development Process
1. **Project Setup**: Create new project with basic Flutter structure
2. **Visual Design**: Use drag & drop to build UI with widgets
3. **Property Configuration**: Customize widget properties using visual editor
4. **Logic Integration**: Add interactive behavior (coming soon)
5. **Live Preview**: See changes in real-time mobile frame
6. **Export & Build**: Generate Flutter project for compilation

---

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph "🎨 Presentation Layer"
        UI[Views & Widgets]
        VM[ViewModels]
    end
    
    subgraph "🔧 Business Logic"
        SVC[Services]
        CTRL[Controllers]
    end
    
    subgraph "📊 Data Layer"
        MODELS[Models & Beans]
        STORAGE[Local Storage]
    end
    
    UI --> VM
    VM --> SVC
    SVC --> CTRL
    CTRL --> MODELS
    MODELS --> STORAGE
    
    style UI fill:#e3f2fd
    style VM fill:#f3e5f5
    style SVC fill:#e8f5e8
    style CTRL fill:#fff8e1
    style MODELS fill:#fce4ec
    style STORAGE fill:#e0f2f1
```

### **MVVM Architecture Pattern**
- **Models**: Data structures and business entities
- **Views**: UI screens and user interfaces  
- **ViewModels**: Business logic and state management
- **Services**: Core functionality and API communication
- **Controllers**: Touch handling and user interactions

---

## 📊 Feature Matrix

| Feature Category | Implementation Status | Description |
|-----------------|---------------------|-------------|
| 🎨 **Visual Editor** | ✅ **Complete** | Drag & drop interface with mobile frame |
| 🔧 **Property System** | ✅ **Complete** | Color-coded property editor with validation |
| 📱 **Touch System** | ✅ **Complete** | Native-like touch handling and gestures |
| 💾 **Code Generation** | ✅ **Complete** | Real-time Flutter code output |
| 🎯 **Widget System** | ✅ **Complete** | Full widget palette with frame components |
| 📦 **Project Management** | ✅ **Complete** | Local project storage and organization |
| 🧩 **Logic Editor** | 🔄 **In Progress** | Block-based programming interface |
| ☁️ **Cloud Integration** | 📅 **Planned** | Cloud build and deployment |

---

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- Android Studio / VS Code
- Git

### Quick Start
```bash
# Clone the repository
git clone https://github.com/sketchide/SketchIDE.git

# Navigate to project directory
cd SketchIDE

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### Project Structure
```
SketchIDE/
├── lib/
│   ├── controllers/        # Touch & interaction handling
│   ├── models/            # Data structures
│   ├── services/          # Business logic services
│   ├── viewmodels/        # MVVM view models
│   ├── views/             # UI screens
│   └── widgets/           # Reusable UI components
├── assets/                # Images, icons, templates
└── android/ios/          # Platform-specific files
```

---

## 🤝 Contributing to the Prototype

We welcome contributions to help improve SketchIDE! Since this is a prototype, we're especially interested in:

### 🎯 **Priority Areas**
- **UI/UX Improvements**: Enhance the visual design experience
- **Performance Optimization**: Improve rendering and responsiveness  
- **Feature Testing**: Help identify bugs and edge cases
- **Documentation**: Improve code documentation and user guides

### 📝 **Contribution Guidelines**
1. Fork the repository and create a feature branch
2. Follow the existing code style and architecture patterns
3. Add appropriate tests for new functionality
4. Submit pull requests with clear descriptions
5. Participate in code reviews and feedback

### 🏷️ **Commit Convention**
```
feat: add new widget to palette
fix: resolve touch handling issue
design: improve property panel UI
test: add unit tests for validation
docs: update README with new features
```

---

## ⚠️ Prototype Disclaimer

**Important Notice**: SketchIDE is currently a **prototype in active development**. 

### What This Means:
- 🔧 **Features may change** without notice during development
- 🐛 **Bugs and issues** are expected and being actively addressed
- 📱 **Not ready for production** app development
- 🔄 **Frequent updates** and changes to the codebase
- 💬 **Feedback is crucial** for improving the final product

### Testing & Feedback:
- Test the visual editor and report any issues
- Suggest improvements for user experience
- Help identify missing features or functionality
- Provide feedback on performance and stability

---

## 📞 Community & Support

<p align="center">
  <a href="https://t.me/sketchidegroup">
    <img src="https://img.shields.io/badge/💬_Join_Community-Telegram-blue?style=for-the-badge" alt="Join Telegram">
  </a>
  <a href="https://t.me/sketchide">
    <img src="https://img.shields.io/badge/📢_Get_Updates-Channel-blue?style=for-the-badge" alt="Telegram Channel">
  </a>
</p>

- **Community Discussion**: [Telegram Group](https://t.me/sketchidegroup)
- **Updates & News**: [Telegram Channel](https://t.me/sketchide)
- **Email Support**: [developerrajendrahelp@gmail.com](mailto:developerrajendrahelp@gmail.com)

---

## 📄 License

SketchIDE is open source software licensed under the **MIT License**.

```
MIT License - Free to use, modify, and distribute
```

This prototype is provided "as-is" for development and testing purposes. See [LICENSE](LICENSE) for full details.

---

<p align="center">
  <img src="https://img.shields.io/badge/Made_with-❤️_and_Flutter-blue" alt="Made with Flutter">
  <br>
  <strong>🚀 Building the future of visual app development 🚀</strong>
</p>
