# Paytm Postpaid: Alternate-Data Credit Risk & Anomaly Detection

A synthetic data science project that demonstrates **credit default prediction**, **risk-based pricing**, **customer segmentation**, and **transaction anomaly** detection for a **Buy Now, Pay Later (BNPL) / postpaid lending product**.

## **Project Overview**

This project simulates a real-world digital lending workflow similar to Paytm Postpaid by leveraging alternative data for underwriting applicants with limited or no traditional credit history. The solution includes:

  - **Credit default** classification using **supervised machine learning**
  - **Risk-based pricing** based on **predicted default probabilities**
  - Transaction anomaly detection for **fraud-screening** use cases
  - **Customer segmentation** using **unsupervised learning**
  - **Fairness and bias-awareness analysis**

## Reproducibility

The project is implemented using Google Colab, with each notebook corresponding to a major stage of the workflow:
  - generate_data.ipynb : The script generates-**`credit_applicants.csv`**,**`txn_behaviour.csv`**
  - EDA_&_Preprocessing.ipynb
  - Classification_models.ipynb
  - Anomaly_detection_and_optional_segmentation.ipynb

Each component is fully standalone. Figures, charts, and result tables are saved to the directory **`credit_risk_lending_ml/`**.

## Part A — EDA and Pre-Processing

**Measured on the raw data:**
- Rows: **400**
- Measured default rate: **20.25%** (81 / 400) — within the 15–25% target band
- Missing `credit_bureau_score`: **80 rows (20.00%)**

  
**Thin-file handling:** The **80 applicants without bureau scores are thin-file applicants**, an important target population for alternate-data underwriting. Dropping them would remove **20% of the dataset** and prevent the model from learning how to score them.


**Instead:** 
  - **`is_thin_file` flag:** is engineered first, directly from raw missingness (`credit_bureau_score.isna()` → 1/0). This is safe to compute before the split because it's a per-row indicator, not a fitted statistic — it carries no information leaked from anywhere else.
  - **Stratified 75/25 train/test split** **(`random_state=42`, `stratify=y`):** happens next, before any imputation. Stratification helps preserve the ~20% minority-class rate in both splits, improving reliable evaluation of precision and recall. The split maintained 20.33% in train and 20.00% in test.
  - **Median imputation, train-only.** The training-set median of `credit_bureau_score` is 612.0 and is used for both train and test missing values. This avoids bias from extreme values, while `is_thin_file` separately captures the missing-bureau-data signal.
  - **Encoding:** `employment_type` (salaried / self_employed / gig) is **one-hot encoded** (`drop_first=True`), not label-encoded, because it's a nominal category with no inherent order — label-encoding as 0/1/2 would **falsely imply gig > self_employed > salaried** numerically, which would mislead the logistic regression coefficient in particular.
  - **Scaling:** numeric features are standardized with `StandardScaler` **fit on the training split only**, then applied to transform both splits — no test-set statistic ever informs the transform.
    
No row is ever dropped anywhere in this pipeline.

## Part B — Classification Models
 
Both models trained on the identical preprocessed split (300 train / 100
test rows).
 
| Model | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| Logistic Regression | 0.760 | 0.389 | 0.350 | 0.368 | **0.719** |
| Decision Tree | 0.650 | 0.222 | 0.300 | 0.255 | 0.519 |
 
Confusion Matrices (`confusion_matrices.png`) and ROC curves
(`roc_curves.png`, side by side with AUC in the legend) are saved as
figures. Full breakdown (TN/FP/FN/TP) is in `part_b_metrics.csv`.
 
### Risk-Based Pricing Table
 
Built from the logistic regression's predicted default probabilities,
bucketed into quartiles on the test set:
 
| Risk tier | N | Avg. predicted P(default) | Observed default rate | Illustrative rate |
|---|---|---|---|---|
| Tier 1 (Lowest risk) | 25 | 0.020 | **8.0%** | 9% – 12% |
| Tier 2 (Low–Med risk) | 25 | 0.073 | **12.0%** | 13% – 17% |
| Tier 3 (Med–High risk) | 25 | 0.234 | **20.0%** | 18% – 24% |
| Tier 4 (Highest risk) | 25 | 0.587 | **40.0%** | 25% – 32% |

Observed default rate rises monotonically from Tier 1 to Tier 4 (8% → 12% → 20% → 40%), confirming the model's ranking is doing real work, not just noise — riskier-scored tiers really do default more often in held-out data, which is the property a risk-based pricing scheme depends on.

## Part C — Anomaly Detection and Segmentation

**Isolation Forest** on standardized `txn_hour`, `is_new_device`, `txn_amount_inr` from `txn_behaviour.csv` (265 rows), with `contamination = 15/265 ≈ 0.0566` matching the seeded anomaly rate:

- **Flagged** **15 / 265** transactions as anomalous (matching the contamination budget, as expected).
- Of the **15 seeded ground-truth anomalies** (`txn_id` starting `BTXNA`), **11 were flagged** → **recall = 73.3% (11/15)**.
- **Scatter plot of hour vs. amount**, with flags and seeded ground truth marked, is at `isolation_forest_scatter.png`.
- The 4 misses are anomalies whose individual feature values **(hour, device novelty, amount)** weren't extreme enough in isolation to separate from the bulk of normal traffic on this particular random draw — a reminder that unsupervised contamination-based detection is a screening tool, not a final decision, and should feed a review queue rather than auto-decline transactions outright.

## Optional / Ungraded
**K-Means Segmentation** `credit_applicants.csv` on its non-bureau numeric features (age, income, existing loans, utilization, UPI inflow, bounced payments), standardized. Calinski-Harabasz index peaked at **k = 2** (score 63.9, monotonically declining for k = 3…7), so k = 2 was used for the final segmentation:
 
| Segment | N | Default rate |
|---|---|---|
| Segment 0 | 187 | **32.1%** |
| Segment 1 | 213 | **9.9%** |

Overall default rate is 20.25%, so **Segment 0 clearly over-indexes on default** (32.1% vs. 20.25% baseline, ~1.6×) —It clusters **higher loans, utilization, and bounced payments, aligning with the target**. 

However, this is a sanity check on feature quality, not a standalone deployment model.

## Part D — Bias-Awareness Note

Even though this dataset has no explicit gender or location field, several of the included variables can act as **correlated proxies for protected attributes** in a real deployment, and that **risk doesn't go away just because the columns are literally about income or credit history**:
 
- **`employment_type`** is a **plausible proxy:** Gig and informal work in India are concentrated among certain demographic and geographic groups. Since gig workers also show more missing bureau scores and higher modeled risk, heavily penalizing `employment_type == gig` could indirectly disadvantage these groups, even without using protected attributes directly.
- **`monthly_income_inr`** correlates with location (urban vs. rural, Tier-1 vs. Tier-3 city) and, at a population level, with gender given labor-force participation and pay gaps — so income can silently reintroduce a location- or gender-correlated signal into a model that never saw those fields.
- **`credit_bureau_score`** itself is a **proxy of a proxy:** Bureau depth and score quality in India is correlated with prior formal-credit access, which is itself unevenly distributed by geography and historically by gender (women and rural applicants are disproportionately "thin-file").
  
**Note:** that **`is_thin_file`** — The very flag this project engineered to be *fair to* new-to-credit applicants — is therefore also a variable to monitor for disparate impact, since it isn't evenly distributed across demographic groups either.

## **Recommended Governance Step Before Going-Live** 
Use a **Maker-Checker Human Review for declined thin-file applicants** (`is_thin_file == 1`).

This can reduce proxy-driven errors, especially where bureau scores are imputed, while creating an audit trail for monitoring potential disparities across employment or geography-related cohorts.

## Final Model Comparison and Recommendation
 
| Metric | Logistic Regression | Decision Tree |
|---|---|---|
| Accuracy | 0.760 | 0.650 |
| Precision | 0.389 | 0.222 |
| Recall | 0.350 | 0.300 |
| F1 | 0.368 | 0.255 |
| ROC-AUC | **0.719** | 0.519 |
| IsolationForest recall (seeded anomalies, shared across both) | 73.3% (11/15) | 73.3% (11/15) |

## Recommendation: 
**Deploy Logistic Regression** 
  - It outperforms the **Decision Tree** across all key metrics, especially **ROC-AUC (0.719 vs. 0.519)**, making its probability rankings more reliable for risk-based pricing.
  - It also has higher **F1 (0.368 vs. 0.255)** and **Precision (0.389 vs. 0.222)**, with better interpretability for credit-risk governance.
  - The **Isolation Forest**, with **73.3% recall** on seeded anomalies, should be used alongside the classifier for transaction monitoring rather than as a replacement.
