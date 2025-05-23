WITH
  # 1. CTE to get the count of transactions per customer per month
  customer_transactions_monthly AS (
    SELECT
      u.id AS customer_id,
      extract(MONTH FROM s.created_on) AS transaction_month,
      COUNT(s.id) AS transaction_count
    FROM users_customuser AS u
    JOIN savings_savingsaccount AS s ON u.id = s.owner_id
    GROUP BY
      u.id,
      extract(MONTH FROM s.created_on)
  ),
  # 2. CTE to calculate the average monthly transactions per customer
  customer_average_transactions AS (
    SELECT
      customer_id,
      AVG(transaction_count) AS avg_transactions_per_month
    FROM customer_transactions_monthly
    GROUP BY
      customer_id
  ),
  # 3. CTE to categorize customers based on average monthly transactions
  customer_categories AS (
    SELECT
      customer_id,
      avg_transactions_per_month,
      CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month >= 3 AND avg_transactions_per_month < 10 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
      END AS frequency_category
    FROM customer_average_transactions
  )
-- 4. Final SELECT statement to aggregate and present the results
SELECT
  frequency_category,
  COUNT(customer_id) AS customer_count,
  AVG(avg_transactions_per_month) AS avg_transactions_per_month
FROM customer_categories
GROUP BY
  frequency_category
ORDER BY
  frequency_category;
