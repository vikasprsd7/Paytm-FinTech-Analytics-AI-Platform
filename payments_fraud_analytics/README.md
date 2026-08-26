# Payments Fraud Analytics

## Project Overview

This project is an end-to-end payments analytics, fraud detection, reconciliation, **SQL, Excel, and Python dashboarding assignment**.

The project creates a deterministic synthetic payments dataset using **seed 42** ***(ensuring that no real Paytm data is used throughout the project)***, injects known fraud patterns and reconciliation discrepancies, analyzes the data using SQL and Excel, reconciles the internal ledger against a gateway export, and presents the results through a four-layer dashboard.
  


## Project Structure

```text
payments_fraud_analytics/
├── generate_data.ipynb            # Data generator (Seed 42)
├── ledger.csv                    # Internal ledger (547 records)
├── users.csv                     # User registry (365 records)
├── merchants.csv                 # Merchant registry (40 records)
├── gateway_export.csv            # Synthetic gateway export
├── reconcile.ipynb               # Payment reconciliation module
├── merchant_workbook.xlsx        # Excel operations & pivot model
├── SQL-Fraud Detection.sql       # SQLite database schema & queries
└── dashboard_charts/             # Visual reporting layer
|   ├── 1_headline_scorecards.png
|   ├── 2_trends_daily_gmv_chargebacks.png
|   ├── 3_breakdown_gmv_method_category.png
|   └── 4_details_top10_merchants.png
├── README.md                     # Project documentation

```
## Workflow of the Project
- **Step 1: Generate the data**

  - Execute all cells in: ***generate_data.ipynb***
  - This generates the four committed CSV files:
    - merchants.csv
    - users.csv
    - ledger.csv
    - gateway_export.csv

  - The generator uses:
    - random.seed(42)
    - np.random.seed(42)
    - Using the same seed makes the generated dataset reproducible.

- **Step 2: Review the Excel workbook**
  - Open: ***merchant_workbook.xlsx***
  - The workbook contains merchant-level analysis, lookup demonstrations, classification logic, Pivot tables and count-versus-unique-count analysis.
 
- **Step 3: Create/query the database**
  - Run the SQL recreation script: ***SQL-Fraud Detection.sql***

  - The database contains the following tables:
    - merchants
    - users
    - transactions
  
The transaction table is linked to the other tables through declared foreign keys.

- **Step 4: Run reconciliation**
  - Execute: ***reconcile.ipynb***
  - The reconciliation function compares: **ledger.csv** against **gateway_export.csv** using **transaction_id**.
 
- **Step 5: Generate dashboard charts**
  - Run: ***Dashboard.ipynb***
  - The notebook creates the saved dashboard images inside:
    - ***dashboard_charts/***
  - The details layer is saved as an image rather than being submitted as a live or printed DataFrame.
