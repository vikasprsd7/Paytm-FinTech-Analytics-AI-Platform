-- Create database
CREATE DATABASE IF NOT EXISTS paytm_payments;
USE paytm_payments;

-- 1. Create merchants table
CREATE TABLE IF NOT EXISTS merchants (
    merchant_id INT PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    region VARCHAR(50)
);

-- 2. Create users table
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY,
    signup_date DATETIME NOT NULL
);

-- 3. Create transactions table with Foreign Keys
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id INT NOT NULL,
    merchant_id INT NOT NULL,
    transaction_time DATETIME NOT NULL,
    amount_inr INT NOT NULL,
    payment_method VARCHAR(50),
    status VARCHAR(20),
    risk_score INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);
-- Running a test to see if Normalization of data has occured properly

SELECT 
    t.transaction_id,
    u.user_id,
    u.signup_date,
    m.merchant_name,
    m.region,
    t.amount_inr,
    t.payment_method,
    t.status
FROM transactions t
JOIN users u ON t.user_id = u.user_id
JOIN merchants m ON t.merchant_id = m.merchant_id
LIMIT 10;

-- Query 1: SELECT / WHERE / ORDER BY / LIMIT — Top 10 highest-value captured transactions with risk_score >= 70

SELECT transaction_id, user_id, merchant_id, transaction_time, amount_inr, payment_method, risk_score
    FROM transactions
    WHERE status = 'captured' AND risk_score >= 70
    ORDER BY amount_inr DESC, transaction_time DESC
    LIMIT 10;
    
-- Query 1b: DISTINCT — Distinct payment methods used in transactions with risk_score >= 70

SELECT DISTINCT payment_method
    FROM transactions
    WHERE risk_score >= 70
    ORDER BY payment_method;

-- Query 2: GROUP BY / HAVING — Merchants with more than 2 chargeback transactions

SELECT merchant_id, COUNT(*) AS chargeback_count, SUM(amount_inr) AS chargeback_total_inr
    FROM transactions
    WHERE status = 'chargeback'
    GROUP BY merchant_id
    HAVING COUNT(*) > 2
    ORDER BY chargeback_count DESC;
    
-- Query 3: INNER JOIN — Chargeback transactions joined with merchant details

SELECT t.transaction_id, t.user_id, t.amount_inr, t.transaction_time,
           m.merchant_name, m.category, m.region
    FROM transactions t
    INNER JOIN merchants m ON t.merchant_id = m.merchant_id
    WHERE t.status = 'chargeback'
    ORDER BY t.transaction_time;

-- Query 4: LEFT JOIN — All users with their transaction count and total spend (includes users with no transactions)

SELECT u.user_id, u.signup_date,
           COUNT(t.transaction_id) AS transaction_count,
           COALESCE(SUM(t.amount_inr), 0) AS total_amount_inr
    FROM users u
    LEFT JOIN transactions t ON u.user_id = t.user_id
    GROUP BY u.user_id, u.signup_date
    ORDER BY transaction_count ASC, u.user_id
    LIMIT 15;
    
-- Query 5: Chargeback impact — count of chargeback transactions, unique users affected, total chargeback amount

SELECT
        COUNT(*) AS chargeback_txn_count,
        COUNT(DISTINCT user_id) AS unique_users_affected,
        SUM(amount_inr) AS total_chargeback_amount_inr
    FROM transactions
    WHERE status = 'chargeback';
    
-- Query 6: Burner accounts — chargeback transactions where 0 <= (transaction_time - signup_date) days < 30

SELECT
    t.transaction_id,
    t.user_id,
    u.signup_date,
    t.transaction_time,
    DATEDIFF(t.transaction_time, u.signup_date) AS account_age_days,
    t.amount_inr,
    t.merchant_id
FROM transactions t
INNER JOIN users u ON t.user_id = u.user_id
WHERE t.status = 'chargeback'
  AND DATEDIFF(t.transaction_time, u.signup_date) >= 0
  AND DATEDIFF(t.transaction_time, u.signup_date) < 30
ORDER BY account_age_days ASC;

-- Query 7: Velocity Attacks- Users with more than 3 transactions within 10 mintutes

SELECT
    user_id,
    FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(transaction_time) / 600) * 600) AS bucket_start,
    COUNT(*) AS txn_count_in_bucket,
    MIN(transaction_time) AS earliest_txn_time,
    MAX(transaction_time) AS latest_txn_time,
    GROUP_CONCAT(transaction_id) AS transaction_ids
FROM transactions
GROUP BY user_id, bucket_start
HAVING COUNT(*) >= 2
ORDER BY user_id, bucket_start;
 
