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

# Detailed Workflow Explanation 
## 1. Data Generation
The synthetic data generator creates a payments ecosystem consisting of gateway_export, merchants, users, and ledger.
- **Merchants**: The dataset contains ***40 merchants.***
- **Users**: The dataset contains ***350 established users.***
- **Ledger**: The dataset consists of ***547 transactions details.***
- **gateway_export**: The dataset consists of ***deliberately-discrepant*** gateway export (~5% missing, ~3% amount-mismatched, ~2% extra, ~2% status-differing, applied on top of the 547-row ledger).

## 2. Excel Merchant Workbook
  - The file: **merchant_workbook.xlsx** contains merchant-level payment analysis.
  - Sheets **merchants, ledger** ***(raw data)***: Sheet ledger adds two helper columns:
    - **txn_date (=INT(transaction_time))**
    - **Is_First_Merchant_Day (a COUNTIFS-based 1/0 flag marking the first transaction for each merchant+day pair)** this is what lets the workbook compute **"unique days"** without needing array formulas or UNIQUE()).
  - Sheet **Fee**: a horizontal (one-row-per-field) MDR-style fee table (payment_method across row 1, MDR Fee % across row 2).
  - Sheet **Merchant_Day_Table**: **(the pivot table)** one row per merchant_id + txn_date combination that actually occurs in the ledger, with Total Amount and Transaction_Count columns (header starts at row 3).
  - **Transaction_view**: one row per transaction, with the **VLOOKUP, HLOOKUP, and classification columns.
  - **Merchant_Status**: A single combined sheet with **total amount + count by merchant × status** and the **count-vs-count-unique** comparison for all 40 merchants (well over the required minimum of 5), appended as extra columns on the same rows rather than spliting into two sheets.

- ### Design Decisions
  - **VLOOKUP with IFERROR** (Transactions_View, Columns C–E)
    -  Used VLOOKUP to retrieve merchant details based on merchant_id.
    - Wrapped with IFERROR to display "Merchant not found" if no matching merchant exists.
    - Used absolute references ($) so the lookup range remains fixed when the formula is copied down all rows.
  - **HLOOKUP Fee Table**: Used a horizontal fee table to assign fee percentages based on payment method. And Fees are looked up automatically using HLOOKUP.
    - Assumed rates:
      - **UPI**: 0.50% (lowest fee)
      - **Wallet**: 1.50%
      - **Card**: 2.00% (highest fee)
      - **Net banking**: 1.80%
  - **Transaction Classification Rule**: Transactions are classified as either "High Value" or "Standard".
    - A transaction is marked High Value when:
      - The merchant's total daily amount is greater than ₹5,000, and
      - The merchant is not located in the East region.
      - Otherwise, it is classified as Standard.
  - **Merchant Daily Total Calculation**: The daily total for each merchant is calculated using SUMIFS.
    - The formula matches both: merchant_id,Transaction date
    - **SUMIFS** was chosen because it can handle multiple matching conditions, unlike a standard VLOOKUP.

  - **Count vs. Unique-Day Analysis**: A comparison is provided for all 40 merchants to show transaction activity.
    - Metrics include:
      - **Total Transaction Count:** Number of transactions for the merchant.
      - **Unique Days Transacted:** Number of distinct days the merchant recorded transactions.
      - **Repeat Day Ratio:** Transactions divided by unique transaction days.
      - **Ratio close to 1 indicates little same-day repeat activity**.
      - **Higher ratios indicate more transactions clustered on the same day**.
      - **Unique-day counts are calculated using the Is_First_Merchant_Day helper flag, avoiding the need for UNIQUE() or COUNTUNIQUE() functions.
  - **Formula-Based Pivot Tables**: All summary tables were built using SUMIFS and COUNTIFS formulas instead of Excel's native PivotTable feature.
    - This approach was chosen because it works reliably with the automated workbook generation process.
    - Formula-based summaries update automatically whenever the source data changes.

## 3. SQL Query Results

  - **Query 1: Top High-Value, High-Risk Captured Transactions**
     - Returned the top 10 captured transactions with risk_score >= 70. Results are ordered by transaction amount in descending order. Used to identify large, potentially risky payments.
  - **Query 1b: Distinct Payment Methods in High-Risk Transactions**
    - Returned the unique payment methods used by transactions with risk_score >= 70. Demonstrates usage of the DISTINCT clause.
  - **Query 2: Merchants with More Than Two Chargebacks**
    - Returned merchants having more than two chargeback transactions. Shows chargeback count and total chargeback amount per merchant. Used for identifying merchants with elevated dispute activity.
  - **Query 3: Chargeback Transactions with Merchant Details**
    -  Joined chargeback transactions to merchant information. Displays merchant name, category, and region along with transaction details. Useful for investigating dispute patterns across merchant segments.
  - **Query 4: User Transaction Summary**
    - Returned all users, including users with no transactions. Shows transaction count and total spending per user. Uses a LEFT JOIN to ensure complete user coverage.
  - **Query 5: Chargeback Impact Summary**
    - Calculated:
      - Total number of chargeback transactions.
      - Number of unique affected users.
      - Total chargeback amount.
      - Provides a platform-level measure of chargeback risk.
  - **Query 6: Burner Account Detection**
    - Identified chargeback transactions from users whose account age was less than 30 days at the time of transaction.
    - Logic filters for: status = 'chargeback', account_age >= 0 days, account_age < 30 days
    - Expected Result: All 15 intentionally injected burner-account fraud records are detected.
  - **Query 7: Velocity Attack Detection**
    - Groups transactions into 10-minute time windows for each user.
    - Flags users with multiple transactions occurring in the same short interval.
    - Expected Result: All 8 seeded velocity-attack clusters are detected. Each cluster contains four closely spaced card transactions.

## 3. Executive Summary: Payment Reconciliation Analysis

An **automated reconciliation workflow** was implemented using **Python (pandas)** to compare the **internal system ledger** against **external payment gateway export** records. The analysis processed **547 internal ledger** records against **530 gateway export* records. The automated **reconcile_payments()** function evaluates data across set-difference operations and inner-join pairwise comparisons to isolate discrepancies into four distinct categories:
  - **Missing in Gateway** (27 transactions / 4.9% of ledger): Transactions recorded internally that are absent from the payment gateway export.
  - **Missing in Ledger / Extra in Gateway** (10 transactions / 1.8% of ledger): Transactions present in the gateway export but unrecorded in the internal ledger.
  - **Amount Mismatches** (16 transactions / 2.9% of ledger): Shared transactions where recorded transaction values (amount_inr) differ between sources, showing variance ranges from -100 to +100 INR.
  - **Status Mismatches** (9 transactions / 1.6% of ledger): Shared transactions with conflicting state records, predominantly consisting of transactions marked as captured or chargeback internally but logged as failed at the gateway.
  - ### Final Result
      -  **Missing in gateway (present in ledger, absent from gateway):** 27  (4.9% of ledger)
      -  **Missing in ledger (extra in gateway):**                        10  (1.8% of ledger)
      -  **Amount mismatches:**                                           16  (2.9% of ledger)
      -  **Status mismatches:**                                           9  (1.6% of ledger)
        
The reconciliation process successfully highlighted operational data gaps across both platforms.

## 4. Dashboard Interpretations
  
All charts are saved as PNG images in **"dashboard_charts/"** . No chart is a live/interactive object — each is a static image, including the details table.
  













  
