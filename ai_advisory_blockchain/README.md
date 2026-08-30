# Paytm Money — AI-Augmented FinTech Advisory & Blockchain Risk (Part 3)

This is a project I built designing an **agentic AI-style toolkit** for a fintech advisory use case. The idea is similar to what a data or financial analyst working in a wealth-tech product might build as an initial prototype.


## What's in this folder

| File                      | What it does                                                                                                              |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `stock_universe.py`       | Seed data for 6 fictional stocks, including beta, analyst-expected return, and standard deviation.                        |
| `investor_profiles.py`    | Seed data for 5 sample investors with risk tolerance, investment horizon, and investment amount.                          |
| `disclosure_snippets.py`  | Six example company-disclosure text snippets used for analysis.                                                           |
| `advisory_agent.py`       | Recommends a portfolio for each investor and decides whether the case should be escalated to a human advisor. |
| `extract_disclosure.py`   | Extracts risk flags, hedging language, and sentiment from a disclosure snippet.                               |
| `debate.py`               | Runs a bull-vs-bear-vs-synthesizer analysis for PAYTECH.                                                      |
| `dcf_calculator.py`       | Performs a DCF valuation, including a sensitivity table and EV/EBITDA cross-check.                            |
| `blockchain_risk_note.md` | A written analysis of crypto and DeFi risks for Paytm Money.                                                  |

## How the "Reasoning" works

Although some parts are described as "Agents," the project does **not actually use an AI model**.

All reasoning-style steps are implemented using standard Python. The narrative outputs are generated with **f-string templates**, while the disclosure analysis uses **keyword and regex-based rules**.

There are also no network or API calls. The entire project runs **offline, deterministically, and only with Python's standard library**.

## How to run the project

No additional packages are required. From the project folder, run:

```bash
advisory_agent.py
extract_disclosure.py
debate.py
dcf_calculator.py
```

The `blockchain_risk_note.md` file is only a written analysis, so it does not need to be executed.

# Part A — Portfolio Advisory Agent

The advisory agent follows a simple **think → act → observe → decide** structure.

### 1. Think

The agent first checks the investor's risk tolerance and selects three stocks using a fixed rule:

  * **Conservative:** PAYBOND, PAYGOLD, PAYRETAIL — equal allocation
  * **Moderate:** PAYRETAIL, PAYINFRA, PAYGOLD — equal allocation
  * **Aggressive:** PAYTECH, PAYFIN, PAYINFRA — equal allocation


### 2. Act

The agent calls `get_stock_data(ticker)` to retrieve the stock's beta and standard deviation.

In a production environment, this could be connected to a market-data API. For this project, the data is stored locally, but the lookup is kept as a separate function to demonstrate the tool-call step.

### 3. Observe and decide

The agent then calculates:

* **Expected portfolio return** using CAPM:

**`E(R) = risk-free rate + beta × (market return - risk-free rate)`**

The three stocks are equally weighted.

* **Portfolio risk** using the standard weighted portfolio variance formula, assuming a **0.3 correlation** between every pair of stocks.

Finally, there is a simple human-escalation rule: if portfolio standard deviation is **above 20%**, the system does not automatically finalize the recommendation. Instead, it returns **`ESCALATED_TO_HUMAN_ADVISOR`**.

### Results for all five investors

| Investor | Risk tolerance | Expected return | Std. dev. | Escalated? |
| -------- | -------------- | --------------: | --------: | ---------- |
| INV01    | Conservative   |           9.20% |     8.44% | No         |
| INV02    | Moderate       |          11.30% |    12.57% | No         |
| INV03    | Aggressive     |          15.00% |    20.58% | **Yes**    |
| INV04    | Moderate       |          11.30% |    12.57% | No         |
| INV05    | Aggressive     |          15.00% |    20.58% | **Yes**    |

The final recommendation sentence is also generated dynamically from the calculated values using a simple f-string template.

# Part B — Disclosure Extraction

`extract_signals(snippet)` takes a disclosure paragraph and returns three outputs:

* `risk_flags`
* `hedging_detected` (`True`/`False`)
* `sentiment` (`confident`, `cautious`, or `neutral`)

The logic is intentionally simple and rule-based.

For example:

* `"litigation"` → `litigation` risk flag
* `"regulatory"` → `regulatory` risk flag
* Customer revenue concentration → `customer_concentration`
* `"assuming"`, `"cautiously"`, or `"visibility"` → hedging detected
* `"confident"` or `"approved"` → confident sentiment
* Hedging language → cautious sentiment
* Otherwise → neutral

### Results

| Snippet | Risk flags               | Hedging detected | Sentiment     |
| ------- | ------------------------ | ---------------- | ------------- |
| doc_01  | []                       | True             | cautious      |
| doc_02  | [litigation]             | False            | neutral       |
| doc_03  | [customer_concentration] | False            | neutral       |
| doc_04  | []                       | True             | cautious      |
| doc_05  | []                       | False            | **confident** |
| doc_06  | [regulatory]             | False            | neutral       |

# Part C — Debate Demo

For the debate example, I selected **PAYTECH** because it has the highest beta and standard deviation in the stock universe, making it more suitable for a bull-vs-bear discussion.

The three components work as follows:

* **Bull:** focuses on expected return and beta.
* **Bear:** focuses on volatility and risk.
* **Synthesizer:** combines both views into a balanced conclusion.

All three outputs are generated from templates using PAYTECH's actual values:

* Beta = **1.55**
* Expected return = **19.0%**
* Standard deviation = **34.0%**

# Part D — DCF Calculator

This section contains a discounted-cash-flow valuation for a fictional Paytm business line.

All assumptions — including EBIT, D&A, CapEx, growth rates, and capital structure — were selected by me for the exercise. They are visible at the top of `dcf_calculator.py` and are also printed when the script runs.

The model:

1. Calculates base **FCFF** using:

**`EBIT × (1 - tax rate) + D&A - CapEx - ΔNWC`**

2. Projects FCFF for five years using a declining growth rate:

**15% → 13% → 11% → 9% → 7%**

The terminal growth rate is **4%**.

3. Calculates **WACC** using CAPM-based cost of equity and after-tax cost of debt, with a capital structure of **70% equity and 30% debt**.

The resulting WACC is **12.6%**, which is more than three percentage points above the 4% terminal growth rate.

4. Calculates terminal value using the growing-perpetuity method, discounts the projected cash flows back to today, and derives Enterprise Value.

5. Generates a **3×3 sensitivity table** using WACC ±1 percentage point and terminal growth ±1 percentage point. In all nine scenarios, WACC remains above terminal growth, so the perpetuity calculation remains valid.

6. Cross-checks the DCF valuation using an **EV/EBITDA multiple of 12x** on an illustrative EBITDA of ₹580 crore.

The DCF valuation is approximately **27% lower** than the multiple-based estimate. The values are still in the same general range, but the difference is worth noting, mainly because the relatively high WACC is conservative compared with the growth assumptions.

# Part E — Blockchain / Crypto Risk Note

`blockchain_risk_note.md` is a written analysis covering three areas.

**First**, it explains what a potential **Paytm Crypto Insights** feature would need to consider before showing stablecoins and DeFi/DAO tokens to retail users. This includes clearly distinguishing stablecoin types and highlighting governance and token-unlock risks.

**Second**, it gives a specific recommendation for crypto allocation in Paytm Money. My conclusion is **zero allocation within the core advisory product**, based on factors such as the lack of traditional cash flows, unstable correlation with traditional assets, fat-tailed returns, and limitations of applying CAPM-style portfolio assumptions to crypto.

**Third**, it applies the **T.A.N.G. fraud framework — Temptation, Authority, Need, and Greed —** to two social-engineering risks relevant to a UPI, wallet, lending, and wealth platform. It also proposes a real-time bank-side control for each case.

# Notes and Possible Improvements

There are a few areas I would improve in a future version.

The DCF currently uses fixed growth assumptions and capital structure inputs. A useful next step would be making these configurable for different business lines rather than hardcoding them.

Similarly, the disclosure-extraction model is based on basic keyword matching. It works for the six sample disclosures used here, but a real-world solution would require a larger labeled dataset and more advanced NLP techniques to handle different writing styles and wording.

