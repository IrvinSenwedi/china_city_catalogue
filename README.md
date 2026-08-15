# China City Catalogue

China City Catalogue is an **intelligent product discovery and reservation platform** built with Flutter and Supabase.

The application is designed to help customers discover products available from different retailers within China City without having to physically visit multiple stores just to check product availability.

Customers can browse products, search the catalogue, receive personalised recommendations, check stock availability and reserve products for collection.

Retailers can manage products and stock, handle customer reservations, and use customer search insights to better understand product demand.

---

## Problem

Customers shopping at China City may need to visit several stores before finding a particular product.

This creates several problems:

- Customers do not know which store has a product.
- Customers cannot easily compare available products.
- Customers may travel to a store only to discover that an item is out of stock.
- Retailers have limited visibility into what customers are actively searching for.
- Retailers may miss opportunities to stock products for which there is customer demand.

China City Catalogue provides a central digital catalogue connecting customer product discovery with retailer inventory information.

---

## Solution

The platform provides two connected experiences:

### For Customers

Customers can:

- Browse products from multiple stores.
- Search for specific products.
- Browse products by category.
- Check prices and stock availability.
- View product details and images.
- Receive personalised product recommendations.
- Discover similar products.
- Reserve products.
- Select a collection time.
- Manage their reservations.
- Update their profile.
- Recover forgotten passwords.

### For Retailers

Retailers can:

- Manage their product catalogue.
- Add and edit products.
- Update stock quantities.
- Manage customer reservations.
- Confirm reservations.
- Mark products as collected.
- Cancel reservations.
- View customer search insights.
- Identify products customers are looking for.

---

# Intelligent Recommendation System

One of the key features of China City Catalogue is its **intelligent recommendation system**.

Rather than showing every customer exactly the same catalogue experience, the system uses customer behaviour to determine products that may be relevant to each user.

## Behavioural Signals

The recommendation system can use interactions such as:

- Products viewed.
- Products reserved.
- Customer searches.
- Product categories interacted with.
- Related or similar products.

These interactions create behavioural signals that can be used to personalise product discovery.

---

## Personalised "For You" Section

The customer home screen contains a **For You** section.

This section recommends products based on the customer's previous activity.

For example:

```text
Customer searches for "Bluetooth speaker"
        ↓
Customer views Bluetooth Speaker
        ↓
System records the interaction
        ↓
Recommendation logic analyses the activity
        ↓
Related products are identified
        ↓
Relevant products appear in "For You"
```

The purpose is to reduce the amount of searching required and make the catalogue more relevant to each customer.

---

## Similar Product Recommendations

Product detail pages can also display similar products.

For example, when viewing a particular electronic product, the system can recommend other related products from the catalogue.

This provides another discovery mechanism and allows customers to explore alternatives.

---

## AI Approach

The current prototype uses **behaviour-based recommendation logic and product relationships** rather than a large generative AI model.

This makes the recommendation system:

- Lightweight.
- Explainable.
- Appropriate for the current catalogue size.
- Less expensive to operate.
- Easier to demonstrate.
- Suitable for an academic prototype.

The architecture can later evolve into a more advanced machine-learning recommendation engine as the platform collects more customer interaction data.

Possible future approaches include:

- Content-based recommendation.
- Collaborative filtering.
- Customer similarity modelling.
- Product similarity scoring.
- Search intent analysis.
- Machine-learning ranking models.

Therefore, the current system demonstrates the **foundation of an AI-driven recommendation platform** without unnecessarily introducing a complex machine-learning model during the prototype stage.

---

# Customer and Retailer Intelligence

Customer behaviour provides value to both sides of the platform.

```text
CUSTOMER SIDE                     RETAILER SIDE

Customer Activity                Customer Demand
       ↓                               ↓
Views                           Searches
Searches                        Search Frequency
Reservations                   Search Trends
       ↓                               ↓
Recommendation Logic            Search Analytics
       ↓                               ↓
"For You"                       Demand Insights
       ↓                               ↓
Better Discovery                Better Stock Decisions
```

### Customer Intelligence

The system asks:

> Based on this customer's activity, what products might they be interested in?

The result is personalised product discovery.

### Retailer Intelligence

The system asks:

> What products are customers searching for?

The result is customer-demand information that can assist retailers with stocking decisions.

This means customer interaction data supports both **personalisation** and **business intelligence**.

---

# Main Features

## Product Catalogue

Customers can browse products available from different stores within China City.

Each product can contain:

- Product name.
- Product image.
- Description.
- Category.
- Price.
- Store information.
- Stock quantity.
- Stock availability.

Products can be filtered by category.

---

## Product Search

The application provides a dedicated product search screen.

Customers can:

- Search by keyword.
- View matching products.
- View recent searches.
- View popular searches.
- Repeat a previous search.
- Open products directly from search results.

Search activity can also contribute to recommendations and retailer demand insights.

---

## Recent Searches

The application remembers recent customer searches.

This allows customers to quickly return to products they were previously interested in without typing the search again.

---

## Popular Searches

The Search screen can also display popular searches based on catalogue search activity.

This provides customers with another product discovery mechanism while demonstrating broader demand across the platform.

---

# Search Insights for Retailers

Retailers can access aggregated search information showing what customers are looking for.

For example, if customers repeatedly search for:

```text
Air Fryer
Wireless Earbuds
Power Bank
Smart Watch
```

retailers can use that information as an indication of customer demand.

The feature is designed to answer questions such as:

> What products are customers currently looking for?

> Are customers searching for products that stores should consider stocking?

This turns search behaviour into useful business information.

---

# Product Reservations

Customers can reserve available products before travelling to a store.

During reservation, customers can select a **collection time**.

A reservation contains information such as:

- Product.
- Quantity.
- Reservation status.
- Collection time.
- Expiry time.

Possible reservation statuses include:

```text
PENDING
CONFIRMED
COLLECTED
CANCELLED
EXPIRED
```

---

## Reservation Lifecycle

A typical reservation follows:

```text
Customer reserves product
        ↓
PENDING
        ↓
Retailer confirms reservation
        ↓
CONFIRMED
        ↓
Customer collects product
        ↓
COLLECTED
```

Alternatively:

```text
PENDING / CONFIRMED
        ↓
Collection period passes
        ↓
EXPIRED
```

A reservation may also be cancelled when appropriate.

The expiry mechanism prevents products from remaining reserved indefinitely when customers do not collect them.

---

# Reservation Management

## Customer

Customers can view and manage their reservations.

Reservation information includes:

- Product.
- Quantity.
- Price.
- Estimated total.
- Reservation status.
- Collection information.

Completed and historical reservations can be separated from active reservations to keep the interface organised.

---

## Retailer

Retailers can see reservations associated with products belonging to their store.

Depending on the current status, retailers can:

- Confirm a reservation.
- Cancel a reservation.
- Mark a reservation as collected.

This creates a simple reservation workflow between customers and physical retailers.

---

# Stock Management

Retailers can maintain the stock quantity of their products.

The customer catalogue communicates availability using states such as:

```text
In Stock
Low Stock
Out of Stock
```

Customers therefore have an indication of product availability before travelling to the store.

---

# Customer Profile

Authenticated customers can manage their profile information from within the application.

This provides customers with control over their account details without requiring them to create another account.

---

# Authentication

China City Catalogue uses **Supabase Authentication**.

Authentication features include:

- Account registration.
- Customer accounts.
- Retailer accounts.
- Email/password sign in.
- Sign out.
- Forgot password.
- Password reset.

The application determines whether the authenticated account belongs to a customer or retailer and displays the appropriate interface.

---

## Password Recovery

Customers who forget their password can request a password-reset email.

The flow is:

```text
Login
   ↓
Forgot Password
   ↓
Enter Email
   ↓
Supabase sends recovery email
   ↓
Customer opens recovery link
   ↓
Application opens
   ↓
Reset Password
   ↓
Create new password
   ↓
Sign in
```

Android deep linking is used to return the customer to the application after opening the recovery email.

The application uses:

```text
chinacitycatalogue://reset-password
```

as its password recovery deep link.

---

# User Roles

The system currently supports two main account types.

## Customer

A customer can:

- Browse products.
- Search products.
- View recent searches.
- View popular searches.
- Receive personalised recommendations.
- View similar products.
- Check stock availability.
- Reserve products.
- Select collection times.
- Manage reservations.
- Manage their profile.

## Retailer

A retailer can:

- Access the retailer dashboard.
- View store products.
- Add products.
- Edit products.
- Update stock quantities.
- Manage reservations.
- Confirm reservations.
- Cancel reservations.
- Mark products as collected.
- View search insights.

---

# Technology Stack

## Frontend

- Flutter
- Dart
- Material 3

## State Management

- Riverpod

## Backend

- Supabase

## Database

- PostgreSQL

## Authentication

- Supabase Auth

## Intelligence & Personalisation

- Behaviour-based product recommendations.
- Product interaction tracking.
- Personalised "For You" recommendations.
- Similar-product discovery.
- Customer search behaviour analysis.
- Retail demand insights.

## Additional Backend Features

- PostgreSQL functions / RPC.
- Row Level Security.
- Authentication state management.
- Recommendation queries.
- Search analytics.
- Reservation lifecycle management.

---

# Project Architecture

The Flutter application uses a feature-based structure.

```text
lib/
├── core/
│   └── theme/
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── presentation/
│   │   ├── providers/
│   │   └── repositories/
│   │
│   ├── catalogue/
│   │   ├── models/
│   │   ├── presentation/
│   │   ├── providers/
│   │   └── repositories/
│   │
│   ├── profile/
│   │
│   ├── recommendations/
│   │
│   ├── reservations/
│   │
│   ├── retailer/
│   │
│   └── search/
│
└── main.dart
```

This keeps functionality grouped by feature and separates presentation, state management, models and data-access responsibilities.

---

# Core Data Model

Core catalogue relationships include:

```text
profiles
   │
   └── stores
         │
         └── products
               │
               └── categories
```

Additional data supports:

```text
Customers
    │
    ├── Reservations
    │
    ├── Search Activity
    │
    └── Product Interactions
              │
              ↓
       Recommendations
```

These relationships allow the catalogue, reservation, search analytics and recommendation features to work together.

---

# Environment Configuration

Create a `.env` file in the project root.

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
```

Sensitive production credentials should never be committed to source control.

---

# Running the Project

## Requirements

Install:

- Flutter SDK.
- Dart SDK.
- Android Studio or VS Code.
- Android emulator or Android device.
- Access to the configured Supabase project.

Check the Flutter environment:

```bash
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# Customer Journey

```text
Register / Sign In
        ↓
Catalogue
        ↓
Browse / Search / Recommendations
        ↓
Product Details
        ↓
Similar Products
        ↓
Reserve Product
        ↓
Choose Collection Time
        ↓
Retailer Confirms
        ↓
Customer Collects
        ↓
Reservation Completed
```

---

# Retailer Journey

```text
Retailer Sign In
        ↓
Retailer Dashboard
        ↓
Manage Products & Stock
        ↓
View Reservations
        ↓
Confirm Reservations
        ↓
Customer Collection
        ↓
Mark Collected
```

At the same time:

```text
Customer Searches
        ↓
Search Activity
        ↓
Retailer Search Insights
        ↓
Understand Customer Demand
        ↓
Potential Stocking Decisions
```

---

# Why This Is Not a Traditional E-Commerce App

China City Catalogue is primarily a **product discovery and reservation platform**, rather than a complete online marketplace.

The prototype does not require customers to complete an online checkout.

Instead:

```text
Discover Online
      ↓
Reserve Online
      ↓
Collect From Physical Store
```

This keeps the platform focused on solving the main problem: helping customers find products and helping retailers understand customer demand.

---

# Future Development

The current architecture can support further development such as:

### Intelligence

- Collaborative filtering.
- Machine-learning recommendation models.
- Search intent understanding.
- Recommendation ranking.
- Demand forecasting.
- Product trend detection.

### Customer Experience

- Favourite products.
- Product availability alerts.
- Reservation reminders.
- Push notifications.
- Store-specific pages.
- Advanced search filters.

### Retailer Experience

- Search analytics dashboards.
- Product demand reports.
- Low-stock alerts.
- Demand forecasting.
- Reservation notifications.
- Product image uploads.

### Platform

- Supabase Storage for product images.
- Administrative dashboard.
- Web application.
- Store verification.
- Advanced analytics.

---

# Project Status

**Functional Academic Prototype**

The current prototype demonstrates the major customer and retailer workflows, including:

- Authentication.
- Product catalogue.
- Product search.
- Recent and popular searches.
- Product images.
- Stock availability.
- Customer profiles.
- Product reservations.
- Collection scheduling.
- Reservation expiry.
- Retailer product management.
- Retailer reservation management.
- Behaviour-based recommendations.
- Similar-product discovery.
- Search-demand insights.
- Password recovery.

---

# Project Vision

China City Catalogue demonstrates how a traditional physical shopping environment can be enhanced using **digital product discovery, intelligent personalisation and customer-demand insights**.

The platform connects three important pieces of information:

```text
WHAT STORES HAVE
       +
WHAT CUSTOMERS WANT
       +
WHAT EACH CUSTOMER LIKES
       ↓
SMARTER PRODUCT DISCOVERY
```

For customers, this means finding relevant products more easily.

For retailers, it means gaining better visibility into customer demand.

The long-term opportunity is to evolve the platform from a simple digital catalogue into an intelligent bridge between physical retailers and their customers.

---

## License

This project was developed for educational and prototype purposes.