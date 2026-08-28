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

Each component is fully standalone. Figures, charts, and result tables are saved to the directory.

## Part A — EDA and preprocessing
**Measured on the raw data:**
- Rows: **400**
- Measured default rate: **20.25%** (81 / 400) — within the 15–25% target band
- Missing `credit_bureau_score`: **80 rows (20.00%)**

  
**Thin-file handling:** The **80 applicants** with no bureau score are **not noise** — they are **new-to-credit / thin-file applicants**, which is exactly the population an alternate-data underwriting model like Paytm Postpaid exists to serve. **Dropping them would throw away a fifth of the dataset and, worse, would systematically remove the very segment the model needs to learn to score.** 

**Instead:** 
  - **`is_thin_file` flag:** is engineered first, directly from raw missingness (`credit_bureau_score.isna()` → 1/0). This is safe to compute before the split because it's a per-row indicator, not a fitted statistic — it carries no information leaked from anywhere else.
  - **Stratified 75/25 train/test split** **(`random_state=42`, `stratify=y`):** happens next, before any imputation. Stratification matters because the target is imbalanced (~20% positive class); an unstratified split risks a fold with a meaningfully different default rate by chance alone, which would distort both training and evaluation — especially recall/precision on the minority "default" class. The realized split preserved the ratio closely: **20.33% train / 20.00% test**.
  - **Median imputation, train-only.** The median of `credit_bureau_score` is computed from the training split alone (**612.0**) and that single value is used to fill missing scores in *both* train and test — the same fit-on-train-only discipline as the scaler below. Median (not mean or a sentinel like 0) gives thin-file applicants a neutral, population-typical score rather than an outlier that would bias the linear/tree models toward treating "missing" as automatically maximum-risk; the real "no bureau data" signal is carried separately by `is_thin_file`, so the model can learn a distinct effect for that population instead of conflating them with genuinely high- or low-scoring applicants. 
  - **Encoding:** `employment_type` (salaried / self_employed / gig) is **one-hot encoded** (`drop_first=True`), not label-encoded, because it's a nominal category with no inherent order — label-encoding as 0/1/2 would **falsely imply gig > self_employed > salaried** numerically, which would mislead the logistic regression coefficient in particular.
  - **Scaling:** numeric features are standardized with `StandardScaler` **fit on the training split only**, then applied to transform both splits — no test-set statistic ever informs the transform.
    
No row is ever dropped anywhere in this pipeline.

## Part B — Classification models
 
Both models trained on the identical preprocessed split (300 train / 100
test rows).
 
| Model | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| Logistic Regression | 0.760 | 0.389 | 0.350 | 0.368 | **0.719** |
| Decision Tree | 0.650 | 0.222 | 0.300 | 0.255 | 0.519 |
 
Confusion matrices (`outputs/confusion_matrices.png`) and ROC curves
(`outputs/roc_curves.png`, side by side with AUC in the legend) are saved as
figures. Full breakdown (TN/FP/FN/TP) is in `outputs/part_b_metrics.csv`.
 
### Risk-based pricing table
 
Built from the logistic regression's predicted default probabilities,
bucketed into quartiles on the test set:
 
| Risk tier | N | Avg. predicted P(default) | Observed default rate | Illustrative rate |
|---|---|---|---|---|
| Tier 1 (Lowest risk) | 25 | 0.020 | **8.0%** | 9% – 12% |
| Tier 2 (Low–Med risk) | 25 | 0.073 | **12.0%** | 13% – 17% |
| Tier 3 (Med–High risk) | 25 | 0.234 | **20.0%** | 18% – 24% |
| Tier 4 (Highest risk) | 25 | 0.587 | **40.0%** | 25% – 32% |
