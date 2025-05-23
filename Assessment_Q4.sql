WITH
  -- CTE 1: Calculate Account Tenure for each customer in months
  customer_tenure AS (
    SELECT
      u.id AS customer_id,
      concat(u.first_name, " ", u.last_name) AS name,
      -- Calculate tenure in months. Use GREATEST(1, ...) to avoid division by zero
      -- for customers who signed up in the current month.
      GREATEST(
        1,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE())
      ) AS tenure_months
    FROM users_customuser AS u
  ),
  -- CTE 2: Summarize transaction data for each customer
  customer_transactions_summary AS (
    SELECT
      s.owner_id AS customer_id,
      COUNT(s.id) AS total_transactions,
      -- Calculate total profit based on 0.1% of each transaction's deposit value
      SUM(s.amount * 0.001) AS total_profit
    FROM savings_savingsaccount AS s
    GROUP BY
      s.owner_id
  )
-- Final SELECT statement to combine data and calculate Estimated CLV
SELECT
  ct.customer_id,
  ct.name,
  ct.tenure_months,
  COALESCE(cts.total_transactions, 0) AS total_transactions, -- Handle customers with no transactions
  -- Calculate Estimated CLV: (Total Profit / Tenure in Months) * 12
  -- COALESCE is used for total_profit in case a customer has no transactions,
  -- ensuring the calculation doesn't result in NULL.
  ROUND(
    (COALESCE(cts.total_profit, 0) / ct.tenure_months) * 12,
    2
  ) AS estimated_clv
FROM customer_tenure AS ct
LEFT JOIN customer_transactions_summary AS cts
  ON ct.customer_id = cts.customer_id
ORDER BY
  estimated_clv DESC;