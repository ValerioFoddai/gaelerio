# Gaelerio - Personal Finance SaaS Platform

## Overview
Gaelerio is a modern personal finance management platform built with Next.js 14 and Supabase, designed to help users track their expenses, manage budgets, and achieve their financial goals.

## Technical Stack
- Frontend: Next.js 14, TailwindCSS
- Backend: Supabase
- Authentication: Supabase Auth
- Database: PostgreSQL (via Supabase)
- State Management: React Context + Hooks
- Styling: TailwindCSS + Custom Components

## Project Structure
```
gaelerio/
├── app/                    # Next.js app directory
│   ├── components/        # Reusable UI components
│   │   ├── ui/           # Basic UI elements
│   │   ├── forms/        # Form components
│   │   └── charts/       # Data visualization
│   ├── auth/             # Authentication related pages
│   └── dashboard/        # Main application views
├── lib/                   # Utilities and configurations
│   ├── supabase/         # Supabase client and utilities
│   ├── hooks/            # Custom React hooks
│   └── utils/            # Helper functions
└── public/               # Static assets
```

## Database Schema

### Tables

#### users
- id: uuid (PK)
- email: string
- created_at: timestamp
- updated_at: timestamp

#### transactions
- id: uuid (PK)
- user_id: uuid (FK)
- amount: decimal
- category_id: uuid (FK)
- description: string
- date: timestamp
- type: enum ('income', 'expense')

#### categories
- id: uuid (PK)
- name: string
- type: enum ('income', 'expense')
- color: string
- icon: string

## API Documentation

### Authentication Endpoints

#### POST /api/auth/signup
Creates a new user account
```typescript
Request:
{
  email: string
  password: string
  name: string
}

Response:
{
  user: User
  session: Session
}
```

#### POST /api/auth/login
Authenticates an existing user
```typescript
Request:
{
  email: string
  password: string
}

Response:
{
  user: User
  session: Session
}
```

### Transaction Endpoints

#### GET /api/transactions
Retrieves user transactions with optional filtering
```typescript
Query Parameters:
{
  startDate?: string
  endDate?: string
  category?: string
  type?: 'income' | 'expense'
}

Response:
{
  transactions: Transaction[]
  total: number
}
```

## Security Measures

### Authentication
- JWT-based authentication via Supabase
- Secure password hashing
- Session management
- Protected API routes

### Data Access
- Row Level Security (RLS) policies in Supabase
- User data isolation
- Input validation and sanitization

## Development Guidelines

### Code Style
- Use TypeScript for type safety
- Follow ESLint configuration
- Use Prettier for code formatting
- Follow component composition patterns

### Git Workflow
1. Create feature branches from `main`
2. Use conventional commits
3. Submit PRs for review
4. Squash merge to main

### Testing Strategy
- Unit tests for utilities and hooks
- Component tests with React Testing Library
- E2E tests with Cypress for critical paths

## Deployment

### Development
1. Clone repository
2. Install dependencies: `npm install`
3. Copy `.env.example` to `.env.local`
4. Set up Supabase environment variables
5. Run development server: `npm run dev`

### Production
1. Build application: `npm run build`
2. Run production server: `npm start`
3. Deploy to preferred platform (Vercel recommended)