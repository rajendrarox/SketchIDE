# 📚 SketchIDE Technical Documentation

<p align="center">
  <img src="https://img.shields.io/badge/Documentation-Technical_Guide-blue?style=for-the-badge" alt="Technical Documentation">
  <img src="https://img.shields.io/badge/Architecture-MVVM-green?style=for-the-badge" alt="MVVM Architecture">
  <img src="https://img.shields.io/badge/Framework-Flutter-cyan?style=for-the-badge" alt="Flutter Framework">
</p>

> **Technical Reference**: Comprehensive documentation covering frameworks, architecture, storage systems, offline SDK integration, and implementation details for SketchIDE.

---

## 🏗️ System Architecture Overview

```mermaid
graph TB
    subgraph "🎨 Presentation Layer"
        UI[UI Screens & Views]
        WIDGETS[Reusable Widgets]
        PROPS[Property Panels]
    end
    
    subgraph "🧠 Business Logic Layer"
        VM[ViewModels]
        SVC[Services]
        CTRL[Controllers]
    end
    
    subgraph "📊 Data Layer"
        MODELS[Data Models]
        STORAGE[Storage Systems]
        CACHE[Cache Management]
    end
    
    subgraph "🔧 Core Systems"
        TOUCH[Touch System]
        RENDER[Rendering Engine]
        CODEGEN[Code Generation]
    end
    
    UI --> VM
    WIDGETS --> VM
    PROPS --> VM
    
    VM --> SVC
    VM --> CTRL
    
    SVC --> MODELS
    CTRL --> MODELS
    
    MODELS --> STORAGE
    MODELS --> CACHE
    
    TOUCH --> CTRL
    RENDER --> SVC
    CODEGEN --> SVC
    
    style UI fill:#e3f2fd
    style VM fill:#f3e5f5
    style SVC fill:#e8f5e8
    style MODELS fill:#fff3e0
    style STORAGE fill:#fce4ec
    style TOUCH fill:#e0f2f1
```

---

## 🛠️ Technology Stack

<table>
<tr>
<th width="33%">🎨 Frontend</th>
<th width="33%">💾 Backend</th>
<th width="34%">🏗️ Build System</th>
</tr>
<tr>
<td>

**Framework**
- Flutter (Dart) 3.19+
- Material Design 3
- Custom Animations

**UI Components**
- Drag & Drop System
- Touch Controllers
- Visual Editor
- Property Panels

**Storage Compliance**
- Scoped Storage (SAF)
- Google Play Compliant
- Secure File Handling

</td>
<td>

**Local Storage**
- JSON Files (All Data)
- File System (Organization)
- Archive Package (Export/Import)

**Data Management**
- Project Metadata (JSON)
- Widget Persistence (JSON)
- Layout Storage (JSON)
- Code Generation Cache (Files)

**Performance**
- Fast File I/O
- Lightweight JSON Parsing
- No Database Overhead

</td>
<td>

**Android**
- Gradle Build System
- APK/AAB Generation
- Material Components

**iOS**
- Xcode Integration
- IPA Generation
- Cupertino Components

**Flutter Pipeline**
- Dart AOT Compilation
- Platform Binaries
- Asset Bundling

</td>
</tr>
</table>

---

## 🎯 MVVM Architecture Implementation

```mermaid
classDiagram
    class View {
        +build() Widget
        +handleUserInput()
        +updateUI()
    }
    
    class ViewModel {
        +widgets List~FlutterWidgetBean~
        +selectedWidget FlutterWidgetBean
        +addWidget()
        +selectWidget()
        +deleteWidget()
        +notifyListeners()
    }
    
    class Model {
        +FlutterWidgetBean
        +SketchIDEProject
        +ViewInfo
        +PropertyData
    }
    
    class Service {
        +PropertyValidationService
        +CodeGenerationService
        +StorageService
        +SelectionService
    }
    
    View --> ViewModel : observes
    ViewModel --> Model : manages
    ViewModel --> Service : uses
    Service --> Model : operates on
    
    style View fill:#e3f2fd
    style ViewModel fill:#f3e5f5
    style Model fill:#e8f5e8
    style Service fill:#fff3e0
```

### **Pattern Benefits**
- ✅ **Clean Separation**: UI logic separated from business logic
- ✅ **Testability**: ViewModels can be unit tested independently
- ✅ **Maintainability**: Changes to UI don't affect business logic
- ✅ **Scalability**: Easy to add new features and screens

---

## 🎨 Visual Editor System

### **Core Components**

```mermaid
mindmap
  root((Visual Editor))
    Mobile Frame
      Fixed 360x640dp Device
      Status Bar Simulation
      Toolbar Integration
      Grid Background
    Widget System
      Drag & Drop Interface
      Property Panel Integration
      Selection Feedback
      Touch Handling
    Property Editor
      Color-coded Properties
      Real-time Validation
      Auto-completion
      Visual Controls
    Code Generation
      Live Flutter Output
      Real-time Sync
      File Management
      Template System
```

### **Widget Palette System**

| Widget Category | Components | Implementation |
|-----------------|------------|----------------|
| **🏗️ Layout** | Column, Row, Stack, Center | `frame_column.dart`, `frame_row.dart` |
| **📝 Basic** | Text, Button, TextField | `frame_text.dart`, `frame_button.dart` |
| **🎨 Visual** | Image, Icon, Container | `frame_icon.dart`, `frame_container.dart` |
| **📱 Material** | AppBar, Scaffold, Card | Material Design widgets |
| **🔧 Input** | Checkbox, Switch, Slider | Interactive components |

---

## 🔄 Touch & Interaction System

```mermaid
sequenceDiagram
    participant User
    participant TouchController
    participant SelectionService
    participant ViewModel
    participant PropertyPanel
    
    User->>TouchController: Tap Widget
    TouchController->>SelectionService: selectWidget(widget)
    SelectionService->>ViewModel: setSelectedWidget(widget)
    ViewModel->>PropertyPanel: notifyListeners()
    PropertyPanel->>User: Show Properties
    
    User->>TouchController: Long Press Widget
    TouchController->>TouchController: startDragOperation()
    TouchController->>ViewModel: onWidgetDragStart()
    
    User->>TouchController: Drag Widget
    TouchController->>ViewModel: onWidgetDragUpdate(position)
    ViewModel->>User: Visual Feedback
    
    User->>TouchController: Drop Widget
    TouchController->>ViewModel: onWidgetDragEnd(position)
    ViewModel->>PropertyPanel: Update Selection
```

### **Touch System Features**
- **🎯 Native Touch Handling**: Android-like touch behavior
- **✋ Gesture Recognition**: Tap, long press, drag, multi-touch
- **🎨 Visual Feedback**: Selection highlighting and animations
- **📱 Multi-device Support**: Responsive touch areas

---

## 📊 Pure JSON Storage Architecture

> **Storage Philosophy**: SketchIDE uses a **pure JSON file-based storage system** for simplicity, portability, and developer transparency. No databases are used - all data is stored in human-readable JSON files.

### **Why JSON-Only Storage?**
- ✅ **Human Readable**: Easy to debug and inspect project data
- ✅ **Version Control Friendly**: Git-friendly text files
- ✅ **Cross-Platform**: Works on any device without database drivers
- ✅ **Simple**: No schema migrations or database overhead
- ✅ **Portable**: Projects can be easily moved between devices

```mermaid
graph LR
    subgraph "🏠 App Sandbox"
        subgraph "📁 Projects"
            P1[Project 1]
            P2[Project 2]
            PN[Project N]
        end
        
        subgraph "⚙️ SDK"
            FLUTTER[Flutter Engine]
            DART[Dart SDK]
            GRADLE[Gradle Tools]
        end
        
        subgraph "💾 Storage"
            JSON[JSON Files]
            LAYOUTS[Layout Files]
            METADATA[Project Metadata]
        end
    end
    
    subgraph "🔄 External"
        SAF[Storage Access Framework]
        EXPORT[Export/Import (.ide)]
    end
    
    P1 --> JSON
    P2 --> LAYOUTS
    PN --> METADATA
    
    JSON --> SAF
    LAYOUTS --> EXPORT
    
    style P1 fill:#e3f2fd
    style JSON fill:#f3e5f5
    style SAF fill:#e8f5e8
```

### **Storage Strategy**

<table>
<tr>
<th width="25%">Storage Type</th>
<th width="25%">Technology</th>
<th width="25%">Use Case</th>
<th width="25%">Benefits</th>
</tr>
<tr>
<td><strong>📱 Project Data</strong></td>
<td>JSON Files</td>
<td>Project metadata, settings, configuration</td>
<td>Human-readable, easy debugging, portable</td>
</tr>
<tr>
<td><strong>🎨 Widget Storage</strong></td>
<td>JSON Files</td>
<td>Layout definitions, widget hierarchies</td>
<td>Version control friendly, simple parsing</td>
</tr>
<tr>
<td><strong>📁 File Organization</strong></td>
<td>File System</td>
<td>Project folders, assets, generated code</td>
<td>Native OS performance, standard structure</td>
</tr>
<tr>
<td><strong>📦 Export/Import</strong></td>
<td>Archive (.ide)</td>
<td>Project backup, sharing, distribution</td>
<td>Compressed, complete project bundles</td>
</tr>
</table>

---

## 🛠️ Offline SDK Integration

### **Why Offline Development?**

```mermaid
pie title Offline Development Benefits
    "No Internet Required" : 35
    "Instant Preview" : 25
    "Local Build Speed" : 20
    "Privacy & Security" : 12
    "Reliability" : 8
```

### **SDK Components & Optimization**

| Component | Original Size | Optimized Size | Optimization Strategy |
|-----------|---------------|----------------|----------------------|
| **Flutter Engine** | ~2.5 GB | ~500 MB | ARM64 only, stripped debug symbols |
| **Dart SDK** | ~800 MB | ~200 MB | JIT + AOT only, minimal tools |
| **Build Tools** | ~1.2 GB | ~300 MB | Essential Gradle components only |
| **Package Cache** | ~500 MB | ~50 MB | Core Flutter packages only |
| **Total** | **~5 GB** | **~1 GB** | **80% size reduction** |

### **SDK Storage Structure**

```
📁 /Android/data/com.sketchide.app/files/sdk/
├── 🔧 flutter_engine/
│   ├── libflutter.so (ARM64)
│   ├── flutter_assets/
│   └── version_info.json
├── 🎯 dart_sdk/
│   ├── bin/dart
│   ├── lib/core/
│   └── version
├── 🏗️ gradle/
│   ├── wrapper/
│   ├── cache/ (minimal)
│   └── gradle.properties
├── 📦 pub_cache/
│   ├── flutter/
│   ├── material_icons/
│   └── cupertino_icons/
└── 📋 sdk_manifest.json
```

---

## 🏗️ Project Structure & Organization

```mermaid
graph TD
    subgraph "📱 SketchIDE Project"
        META[📋 meta.json]
        ICON[🎨 icon.png]
        
        subgraph "📱 Flutter Structure"
            LIB[📁 lib/]
            ASSETS[📁 assets/]
            ANDROID[📁 android/]
            IOS[📁 ios/]
            PUBSPEC[📄 pubspec.yaml]
        end
        
        subgraph "🎨 SketchIDE Data"
            UI[📁 ui/ - Layout JSON]
            LOGIC[📁 logic/ - Block Data]
            WIDGETS[📁 widgets/ - Widget Cache]
        end
        
        subgraph "🏗️ Build Output"
            APK[📱 app-release.apk]
            AAB[📦 app-release.aab]
            IPA[🍎 app-release.ipa]
        end
    end
    
    META --> LIB
    ICON --> ANDROID
    ICON --> IOS
    
    UI --> LIB
    LOGIC --> LIB
    WIDGETS --> LIB
    
    LIB --> APK
    ANDROID --> APK
    IOS --> IPA
```

### **Project Metadata Example**

```json
{
  "appName": "MySketchApp",
  "packageName": "com.example.mysketchapp",
  "version": "1.0.0",
  "description": "Created with SketchIDE",
  "framework": "flutter",
  "targetSdk": {
    "android": "34",
    "ios": "17.0"
  },
  "features": [
    "material_design",
    "cupertino_design",
    "offline_build"
  ],
  "created": "2024-01-15T10:30:00Z",
  "lastModified": "2024-01-15T15:45:00Z",
  "buildNumber": 1
}
```

---

## 🔄 Code Generation Pipeline

```mermaid
flowchart LR
    subgraph "🎨 Visual Design"
        DRAG[Drag Widget]
        PROPS[Set Properties]
        LAYOUT[Arrange Layout]
    end
    
    subgraph "🔄 Processing"
        BEAN[Widget Bean]
        VALIDATE[Validation]
        TRANSFORM[Transform]
    end
    
    subgraph "📝 Code Output"
        DART[Dart Code]
        IMPORTS[Auto Imports]
        STRUCTURE[File Structure]
    end
    
    subgraph "🏗️ Build"
        COMPILE[Flutter Build]
        APK[APK Output]
        PREVIEW[Live Preview]
    end
    
    DRAG --> BEAN
    PROPS --> VALIDATE
    LAYOUT --> TRANSFORM
    
    BEAN --> DART
    VALIDATE --> IMPORTS
    TRANSFORM --> STRUCTURE
    
    DART --> COMPILE
    IMPORTS --> APK
    STRUCTURE --> PREVIEW
    
    style DRAG fill:#e3f2fd
    style BEAN fill:#f3e5f5
    style DART fill:#e8f5e8
    style COMPILE fill:#fff3e0
```

### **Generated Code Quality**
- ✅ **Clean Dart Code**: Properly formatted and structured
- ✅ **Best Practices**: Follows Flutter conventions
- ✅ **Performance Optimized**: Efficient widget trees
- ✅ **Maintainable**: Human-readable output

---

## 🔐 Security & Compliance

### **Google Play Compliance**

```mermaid
graph LR
    subgraph "🔒 Scoped Storage"
        SANDBOX[App Sandbox]
        SAF[Storage Access Framework]
        PRIVACY[Privacy Controls]
    end
    
    subgraph "📱 Permissions"
        MINIMAL[Minimal Permissions]
        RUNTIME[Runtime Requests]
        TRANSPARENT[User Transparency]
    end
    
    subgraph "✅ Play Store"
        REVIEW[Automated Review]
        POLICY[Policy Compliance]
        APPROVAL[Store Approval]
    end
    
    SANDBOX --> MINIMAL
    SAF --> RUNTIME
    PRIVACY --> TRANSPARENT
    
    MINIMAL --> REVIEW
    RUNTIME --> POLICY
    TRANSPARENT --> APPROVAL
    
    style SANDBOX fill:#e8f5e8
    style MINIMAL fill:#fff3e0
    style REVIEW fill:#e3f2fd
```

### **Security Features**
- 🔒 **Sandboxed Storage**: All data within app boundaries
- 🛡️ **No Legacy Permissions**: Uses modern Android APIs
- 🔐 **Secure Export/Import**: SAF for external file operations
- ✅ **Play Store Compliant**: Passes automated security scans

---

## 🚀 Performance Optimization

### **Rendering Performance**

| Optimization | Implementation | Benefit |
|--------------|----------------|---------|
| **Widget Caching** | Cached widget trees | 60% faster rendering |
| **Touch Optimization** | Native touch handling | Smooth 60fps interaction |
| **Code Generation** | Incremental updates | Real-time feedback |
| **Memory Management** | Efficient disposal | Reduced memory usage |

### **Build Performance**

```mermaid
gantt
    title Build Performance Timeline
    dateFormat X
    axisFormat %s
    
    section Optimized Build
    Parse Widgets    : 0, 2
    Generate Code    : 2, 4
    Compile Dart     : 4, 8
    Package APK      : 8, 12
    
    section Standard Build
    Parse Widgets    : 0, 3
    Generate Code    : 3, 8
    Compile Dart     : 8, 18
    Package APK      : 18, 25
```

---

## 🔮 Roadmap & Future Enhancements

### **Short Term (Next 3 Months)**
- 🧩 **Block-based Logic Editor**: Visual programming interface
- ☁️ **Cloud Sync**: Project synchronization across devices
- 📱 **Multi-screen Support**: Navigation and routing
- 🎨 **Advanced Animations**: Transition and motion support

### **Medium Term (6 Months)**
- 🤖 **AI Code Assistant**: Smart suggestions and optimization
- 🔌 **Plugin System**: Custom widget extensions
- 📊 **Analytics Integration**: App usage insights
- 🌐 **Web Preview**: Browser-based app testing

### **Long Term (12 Months)**
- 🖥️ **Desktop Support**: Windows, macOS, Linux apps
- 🤝 **Team Collaboration**: Real-time multi-user editing
- 📈 **Performance Profiler**: Built-in optimization tools
- 🏪 **Template Marketplace**: Community-driven templates

---

## 📚 API Reference & Examples

### **Widget Bean Structure**
```dart
class FlutterWidgetBean {
  final String id;
  final String type;
  final Map<String, dynamic> properties;
  final WidgetPosition position;
  final LayoutBean layout;
  final String? parentId;
  
  // Methods
  FlutterWidgetBean copyWith({...});
  Map<String, dynamic> toJson();
  static FlutterWidgetBean fromJson(Map<String, dynamic> json);
  static String generateId(String type, List<FlutterWidgetBean> existing);
}
```

### **Property Validation Example**
```dart
// Text property validation
PropertyValidationResult validateTextProperty(String value) {
  if (value.isEmpty) {
    return PropertyValidationResult.error("Text cannot be empty");
  }
  if (value.length > 100) {
    return PropertyValidationResult.warning("Text is very long");
  }
  return PropertyValidationResult.success();
}
```

### **Touch Controller Integration**
```dart
class MobileFrameTouchController {
  void setCallbacks({
    required Function(FlutterWidgetBean) onWidgetSelected,
    required Function(FlutterWidgetBean, Offset) onWidgetDragStart,
    required Function(FlutterWidgetBean, Offset) onWidgetDragUpdate,
    required Function(FlutterWidgetBean, Offset) onWidgetDragEnd,
  });
}
```

---

## 🛠️ Development Setup & Build Instructions

### **Prerequisites**
- Flutter SDK 3.19.0+
- Dart SDK 3.2.0+
- Android Studio / VS Code
- Git for version control

### **Local Development**
```bash
# Clone repository
git clone https://github.com/sketchide/SketchIDE.git

# Install dependencies
cd SketchIDE
flutter pub get

# Run development build
flutter run

# Generate production build
flutter build apk --release
```

### **Testing Strategy**
- **Unit Tests**: ViewModel and service testing
- **Widget Tests**: UI component validation
- **Integration Tests**: End-to-end user workflows
- **Performance Tests**: Memory and rendering benchmarks

---

<p align="center">
  <img src="https://img.shields.io/badge/Architecture-Clean_&_Scalable-green?style=for-the-badge" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/Performance-Optimized-blue?style=for-the-badge" alt="Performance Optimized">
  <img src="https://img.shields.io/badge/Security-Compliant-red?style=for-the-badge" alt="Security Compliant">
</p>

<p align="center">
  <strong>📖 Technical documentation for building the future of visual app development</strong>
</p>

### **JSON Storage Organization**

```
📁 /.sketchide/data/mysc/
├── 📁 project_001/
│   ├── 📄 project.json          # Project metadata
│   ├── 📁 layouts/
│   │   ├── 📄 main.json         # Main layout widgets
│   │   └── 📄 activity_page.json # Additional layouts
│   ├── 📁 lib/
│   │   ├── 📄 main.dart         # Generated Flutter code
│   │   └── 📄 custom_page.dart  # Additional Dart files
│   └── 📁 assets/
│       └── 📄 images/           # Project assets
```

### **Example JSON Structures**

**Project Metadata (`project.json`)**:
```json
{
  "appName": "MySketchApp",
  "packageName": "com.example.myapp",
  "version": "1.0.0",
  "widgets": ["text", "button", "container"],
  "created": "2024-01-15T10:30:00Z"
}
```

**Widget Layout (`main.json`)**:
```json
{
  "layoutName": "main",
  "widgets": [
    {
      "id": "text1",
      "type": "Text",
      "properties": {
        "text": "Hello World",
        "fontSize": 16.0
      },
      "position": {"x": 10, "y": 20, "width": 200, "height": 50}
    }
  ],
  "timestamp": "2024-01-15T15:45:00Z"
}
```

---

