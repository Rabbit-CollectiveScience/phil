# Project Boilerplate

A monorepo boilerplate with Next.js backend and Flutter mobile app using clean architecture patterns.

## 🚀 Project Overview

This boilerplate provides a solid foundation for building full-stack applications with:
- **Backend**: Next.js + TypeScript API with clean architecture
- **Mobile**: Flutter app with clean architecture
- **Infrastructure**: Docker, Google Cloud Platform integration templates

## 📁 Repository Structure

```
project/
├── apps/
│   ├── mobile/          # Flutter mobile app (Android, iOS, Web)
│   └── backend/         # Next.js API server
├── docs/                # Documentation templates
├── shared/              # Shared utilities
├── deployment/          # Deployment configs
└── package.json         # Monorepo workspace configuration
```

## 🛠️ Tech Stack

### Backend (Next.js)
- **Framework**: Next.js 16+ with TypeScript
- **Architecture**: Clean Architecture (Domain/Data/Infrastructure layers)
- **Database**: Configure your preferred database
- **Storage**: Google Cloud Storage template included

### Mobile (Flutter)
- **Framework**: Flutter 3.x with Dart
- **State Management**: Provider
- **Architecture**: Clean Architecture (3-layer)
- **Platforms**: Android, iOS, Web

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Node.js 18+ and npm 9+
- Docker (optional)

### Installation & Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd <your-project>

# Install all dependencies
npm run setup

# Start development servers
npm run dev:backend    # Start API server
npm run dev:mobile     # Start Flutter app
```

### Environment Configuration

Create `.env.local` in `apps/backend/`:
```env
NODE_ENV=development
MONGO_URL=your-database-url
PUBLIC_BASE_URL=http://localhost:3000
UPLOAD_DIR=/tmp/uploads

# Add your environment variables here
```

## 📱 Features Template

- ✅ Clean Architecture patterns
- ✅ Monorepo workspace setup
- ✅ Docker configuration
- ✅ TypeScript + ESLint configuration
- ✅ Testing infrastructure (Jest)
- ✅ Google Cloud integration templates

## 🎯 Development Commands

### Monorepo Management
```bash
npm run setup          # Install all dependencies
npm run build          # Build all applications
npm run test           # Run all tests
npm run clean          # Clean all build artifacts
```

### Backend Commands
```bash
npm run dev:backend    # Start development server
npm run build:backend  # Build for production
npm run test:backend   # Run backend tests
```

### Mobile Commands
```bash
npm run dev:mobile            # Run Flutter app
npm run build:mobile          # Build Android APK
npm run build:mobile:ios      # Build iOS app
npm run test:mobile           # Run Flutter tests
```

## �� Documentation

See the `docs/` folder for comprehensive documentation templates:

- Architecture overview
- API documentation template
- Deployment guides
- Testing strategies

## 🏗️ Architecture

Both backend and mobile follow **Clean Architecture** principles with clear separation of concerns:

### Backend Layers
- **l2_domain/**: Business logic and domain models
- **l3_data/**: Data access and repositories
- **l4_infra/**: External services and infrastructure

### Mobile Layers
- **l1_ui/**: User interface components
- **l2_domain/**: Business logic and models
- **l3_service/**: External services and APIs

## 🚢 Deployment

See `docs/deployment-cloud-run.md` for deployment instructions.

## 📝 License

TODO: Add your license here.

## 🤝 Contributing

TODO: Add contributing guidelines.
