# Paytm Analytics Capstone: Payments, Credit Risk & AI Advisory

## Overview

This repository is a single, connected submission built for Paytm's analytics guild, covering the three tooling stacks a financial data analyst is expected to move across: **spreadsheets/SQL** for **payments operations**, applied **ML** for **credit decisioning**, and **AI-assisted** reasoning for **wealth advisory**. 
  - **NOTE:** All datasets are synthetic and seeded for reproducibility — no real Paytm data is used anywhere in this repo.

```
/payments_fraud_analytics    → Payments ops, fraud SQL, Excel, reconciliation, dashboarding
/credit_risk_lending_ml      → Credit default ML, risk pricing, anomaly detection, segmentation
/ai_advisory_blockchain      → Rule-based advisory agent, DCF, disclosure NLP, crypto risk note
```

## Part 1 — Payments & Fraud Analytics (`/payments_fraud_analytics`)

A deterministic synthetic payments dataset (seed 42: 547 ledger transactions, 365 users, 40 merchants) with injected fraud patterns and reconciliation gaps, analyzed across three tools.

- **Excel (`merchant_workbook.xlsx`)**: VLOOKUP/HLOOKUP-based merchant and fee lookups, SUMIFS/COUNTIFS-driven pivot tables (no native PivotTable feature, so the workbook regenerates automatically), a High Value vs. Standard classification rule, and a repeat-day ratio analysis across all 40 merchants.
- **SQL (`SQL-Fraud Detection.sql`)**: Seven queries covering high-risk captured transactions, chargeback concentration, a LEFT JOIN user summary, burner-account detection (15/15 seeded cases caught), and 10-minute velocity-attack clustering (8/8 seeded clusters caught).
- **Reconciliation (`reconcile.ipynb`)**: A pandas-based reconciliation of the 547-row ledger against a 530-row gateway export, splitting discrepancies into four buckets — missing in gateway (4.9%), missing in ledger (1.8%), amount mismatches (2.9%), and status mismatches (1.6%).
- **Dashboard (`dashboard_charts/`)**: Four static PNG layers — scorecards, trends, breakdowns, and a merchant detail table — flagging an 85.6% success rate against a comparatively high 5.12% chargeback ratio, and a UPI-dominant GMV mix (54.7%).

## Part 2 — Credit Risk & Anomaly Detection (`/credit_risk_lending_ml`)

A BNPL-style postpaid lending pipeline (400 applicants, ~20% default rate) built across four Colab notebooks.

- **Preprocessing**: Thin-file applicants (20% missing bureau score) are flagged rather than dropped, using a leak-safe `is_thin_file` indicator computed pre-split. A stratified 75/25 split, train-only median imputation, one-hot encoding for employment type, and train-fit standard scaling round out the pipeline.
- **Classification**: Logistic Regression (ROC-AUC 0.719) outperforms a Decision Tree (ROC-AUC 0.519) and is the recommended model on precision, recall, and interpretability grounds. Its predicted probabilities feed a four-tier risk-based pricing table where observed default rates rise monotonically from 8% to 40% across tiers — evidence the ranking holds up on held-out data.
- **Anomaly Detection**: An Isolation Forest on transaction hour, device novelty, and amount catches 11 of 15 seeded fraud cases (73.3% recall), intended as a review-queue screen rather than an auto-decline trigger.
- **Segmentation (optional)**: K-Means at k=2 splits applicants into a higher-risk cluster (32.1% default rate) and a lower-risk cluster (9.9%), used as a feature-quality sanity check rather than a deployment model.
- **Bias-Awareness Note**: Employment type, income, and bureau score are flagged as plausible proxies for gender and geography, with a maker-checker human review recommended for declined thin-file applicants before any go-live.

## Part 3 — AI Advisory & Blockchain Risk (`/ai_advisory_blockchain`)

A fully offline, rule-based "agentic" toolkit — no live model calls, just deterministic Python logic — simulating how a wealth-tech analyst might prototype advisory tooling.

- **Advisory Agent**: A think → act → observe → decide loop assigns portfolios by risk tolerance, computes CAPM expected return and weighted portfolio variance, and escalates any investor with portfolio std. dev. above 20% to a human advisor (2 of 5 sample investors trigger escalation).
- **Disclosure Extraction**: Keyword/regex rules tag six sample disclosure snippets for litigation, regulatory, and concentration risk, hedging language, and sentiment.
- **Debate Demo**: A templated bull/bear/synthesizer analysis on PAYTECH, the highest-beta stock in the universe.
- **DCF Calculator**: Five-year FCFF projection with declining growth, CAPM-based WACC (12.6%), a 3×3 sensitivity table, and an EV/EBITDA cross-check showing the DCF running roughly 27% below the multiple-based estimate.
- **Blockchain Risk Note**: A written recommendation of zero core-product crypto allocation, plus a T.A.N.G. fraud-framework analysis of two social-engineering risks relevant to a UPI/wallet/lending platform.

## A Note on Data & Scope

Every number in this repository is synthetic and generated from documented, seeded scripts — this was a deliberate choice to keep the project fully reproducible and shareable without touching any proprietary or real user data. The techniques, however reconciliation logic, fraud SQL, leak-safe ML preprocessing, and CAPM-based advisory reasoning mirror the actual analyst workflows these three Paytm business lines would run in production.
