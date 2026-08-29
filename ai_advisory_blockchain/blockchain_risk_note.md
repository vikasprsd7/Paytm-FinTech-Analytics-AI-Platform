# Blockchain / Crypto Risk Note

## 1. Key risks Paytm Crypto Insights must handle

A crypto watchlist may appear low-risk because it only displays market prices. However, once a mass-retail platform such as Paytm surfaces stablecoins and DeFi/DAO tokens, it can be perceived as indirectly validating these assets. The main challenge is making sure users understand the risks behind the numbers.

### Stablecoin risk

“Stablecoin” does not necessarily mean “safe.” The risk depends heavily on how the token maintains its peg.

A **fiat-collateralized stablecoin** is generally backed by cash or short-term government securities held with a custodian. Its main risk is therefore linked to the quality and availability of those reserves, as well as custodial and counterparty risk.

An **algorithmic or crypto-collateralized stablecoin** works differently. Its peg is maintained through mechanisms such as minting and burning tokens, arbitrage incentives, or volatile crypto collateral. These mechanisms can work under normal market conditions but can break down rapidly when confidence falls. TerraUSD in 2022 is a clear example of how quickly a stablecoin can lose its peg.

Therefore, any Paytm feature listing stablecoins should clearly identify whether they are **fiat-collateralized, crypto-collateralized, or algorithmic**. It should also include a simple warning that “stable” refers to a target price and does not guarantee that the token will remain at that price.

### DeFi and DAO governance risk

DeFi tokens often also function as governance tokens, allowing holders to vote on protocol changes, treasury decisions, or other operational matters. This creates risks that are different from traditional listed securities.

Governance can become concentrated among a small number of large token holders, often called **whales**. Low voting participation can also allow a relatively small group to influence important decisions. In some protocols, a governance attack could directly affect how funds are managed, while blockchain transactions may be difficult or impossible to reverse.

Token unlocks are another important consideration. Large scheduled releases of tokens held by founders or early investors can increase selling pressure, even when the underlying protocol has strong usage.

For this reason, a responsible crypto insights feature should show more than price and market capitalization. It should also provide **governance concentration, voting participation, token unlock schedules, and other basic risk indicators**.

## 2. Recommended crypto allocation for Paytm Money

From a portfolio-construction perspective, cryptocurrency does not fit neatly into traditional CAPM-style asset allocation. CAPM and similar mean-variance approaches are generally easier to apply to assets with identifiable cash flows, such as dividends, coupons, or rental income.

Most cryptocurrencies do not generate contractual cash flows. Their value is primarily determined by market demand and what another buyer is willing to pay. Crypto returns also tend to show **fat tails and large drawdowns**, which are not well captured by standard normal-distribution assumptions.

There are additional data limitations. Historical crypto datasets can suffer from **survivorship bias**, because failed tokens, projects, or exchanges may disappear from the sample. Retail investors also face higher spreads, trading fees, custody costs, and, for some assets, network fees.

Crypto is sometimes justified through its diversification benefits because its correlation with stocks and bonds can be relatively low. However, this relationship is not stable. Correlations can increase significantly during periods of broad market stress, reducing the diversification benefit when it matters most.

Based on these factors, my recommendation would be **zero cryptocurrency allocation in Paytm Money's model portfolios or robo-advisory recommendations**.

This does not mean cryptocurrency is unsuitable for every investor. A sophisticated investor who understands the risks may choose to hold crypto independently. However, a mass-market advisory product should be more conservative when recommending assets to retail investors, particularly when the product is designed around risk profiling and portfolio suitability.

If Paytm Money wants to provide crypto access, I would place it in a **separate, explicitly opt-in self-directed section**, with dedicated risk disclosures rather than including it in optimized model portfolios.

## 3. T.A.N.G. fraud framework for a UPI, wallet, lending and wealth platform

The **T.A.N.G. framework — Temptation, Authority, Need and Greed —** explains how fraudsters use emotional triggers to make victims act quickly without verifying the situation.

Two areas are particularly relevant to a financial platform.

### Authority: Fake bank, RBI or KYC calls

Fraudsters may impersonate a bank employee, RBI representative, or platform support agent and claim that the user's KYC has expired or that a loan requires verification. They may pressure the user to provide an OTP, install screen-sharing software, or approve a UPI collect request.

A strong bank-side defense would be **real-time behavioral and device-risk scoring** at the point of OTP entry or UPI approval. Signals such as an unrecognized device, screen-sharing software, or unusual activity immediately following an inbound call could trigger additional authentication or temporarily hold the transaction.

### Greed: Fake investment or loan offers

Another common fraud pattern involves unrealistic “guaranteed returns,” fake investment groups, or fraudulent loan applications asking users to pay an upfront processing fee. These scams exploit the desire for quick financial gains.

A practical bank-side defense is **real-time beneficiary risk scoring and payment-velocity monitoring**. Payments to newly created or previously reported VPAs or merchant IDs could receive additional scrutiny. A sudden increase in payments to a new beneficiary could also trigger rate limits or transaction controls.

Overall, the key lesson is that social-engineering fraud is specifically designed to manipulate user judgment. Customer awareness is important, but it should not be the only control. For a platform handling UPI, lending and wealth products, **real-time transaction and behavioral controls should form a critical layer of fraud prevention**.
