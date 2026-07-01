# Money Me — Navigation Flow & Prototype Map

```
                   ┌──────────────────────────┐
                   │      AuthGate             │
                   │  (initial / loading /      │
                   │   authenticated / error)   │
                   └────────┬─────────────────┘
                            │
              ┌─────────────┴──────────────┐
              ▼                            ▼
   ┌──────────────────┐        ┌──────────────────────┐
   │   LoginPage       │        │    OnboardingPage     │
   │   (toggle in-     │───────▶│   (4 slides +         │
   │    place regis-   │        │    currency select)    │
   │    ter)           │        └──────────┬───────────┘
   └──────────────────┘                    │
                                          ▼
                              ┌──────────────────────┐
                              │    AppShell           │
                              │  (BottomNav mobile /  │
                              │   Rail tablet /       │
                              │   Drawer desktop)     │
                              └──┬───┬───┬───┬───┬───┘
                                 │   │   │   │   │
          ┌──────────────────────┘   │   │   │   └──────────────┐
          │        ┌─────────────────┘   │   └────────────────┐ │
          ▼        ▼        ┌────────────┘                    ▼ ▼
   ┌─────────┐ ┌────────┐ ┌──────────┐  ┌──────────┐  ┌──────────────┐
   │Dashboard│ │Transact│ │Analysis  │  │Predictns │  │    OCR       │
   │  Page   │ │  Page  │ │  Page    │  │  Page    │  │   Page       │
   │         │ │        │ │          │  │          │  │              │
   │•Summary │ │•Search │ │•Income/  │  │•Forecast │  │•Scan Tab     │
   │•Trends  │ │•Filter │ │ Expense  │  │  amount  │  │  (Take photo │
   │•PieChart│ │•Sort   │ │•Category │  │•Income   │  │   Gallery    │
   │•TopCat  │ │•Pagina │ │  Trends  │  │  pattern │  │   Multi)     │
   │•Budgets │ │•CRUD   │ │•Alerts   │  │•Tips     │  │•History Tab  │
   │•Alerts  │ │        │ │          │  │          │  │•Manual entry │
   └────┬────┘ └───┬────┘ └──────────┘  └──────────┘  └──────┬───────┘
        │          │                                           │
        │          ▼                                           ▼
        │   ┌──────────────┐                          ┌──────────────┐
        │   │ Transaction  │                          │  Preview      │
        │   │  Detail      │                          │  (single /    │
        │   │  (edit/      │                          │   multi)      │
        │   │   delete)    │                          └──────┬───────┘
        │   └──────────────┘                                 │
        │                                                    ▼
        │   ┌──────────────┐                          ┌──────────────┐
        │   │ Categories   │                          │  Review       │
        │   │  Management  │                          │  (edit fields │
        │   └──────────────┘                          │   confirm/    │
        │                                             │   discard)    │
        │   ┌──────────────┐                          └──────────────┘
        │   │ Wallets Page │
        │   │  (CRUD)      │
        │   └──────────────┘
        │
        ▼
  ┌─────────────────────────────────────┐
  │         Settings Page               │
  │  • Preferences (currency, theme,    │
  │    locale, notifications)           │
  │  • Export transactions (CSV/PDF)    │────▶ ExportPage
  │  • Delete Account                   │
  └─────────────────────────────────────┘

## Screen States Matrix

| Screen           | Loading | Empty | Error | Success |
|-----------------|---------|-------|-------|---------|
| Login           | Spinner | —     | Msg   | →AppShell|
| Onboarding      | —       | —     | —     | →AppShell|
| Dashboard       | Skeleton| Msg   | Retry | Data    |
| Transactions    | Skeleton| Msg   | Retry | Data    |
| Transaction Det | —       | —     | Toast | Back    |
| Analysis        | Spinner | Hidden| Msg   | Data    |
| Predictions     | Spinner | Hidden| Msg   | Data    |
| OCR Scan        | —       | Msg   | Alert | Preview |
| OCR Review      | —       | —     | Alert | Confirm |
| OCR History     | List    | Msg   | Msg   | Data    |
| Budgets         | Skeleton| Msg   | Msg   | Data    |
| Export          | Button  | —     | Banner| Download|
| Categories      | List    | Msg   | Snack | Data    |
| Wallets         | List    | Msg   | Snack | Data    |
| Settings        | —       | —     | Snack | Toast   |
| Profile         | —       | —     | Snack | Toast   |

## CTA Visibility Rules

1. Every list screen has a FAB for primary action (add transaction, add budget, add category)
2. Every form screen has the submit button at the bottom, full-width on mobile
3. Error states always include a visible retry button
4. Empty states always include a CTA to create the first item
5. Destructive actions (delete) require a confirmation dialog
6. Save/Cancel pairs appear together, Cancel on the left

## Navigation Patterns

- **Mobile**: BottomNavigationBar with 5 items (Dashboard, Transactions, Analysis, Predictions, Scan)
- **Tablet**: NavigationRail + content
- **Desktop**: Drawer (240px) + content
- **Modals**: Bottom sheets for filters, sort, and quick picks
- **Dialogs**: Confirmation for destructive actions
- **Push**: Detail pages, full-screen capture, export
- **Back**: WillPopScope with nav history tracking
