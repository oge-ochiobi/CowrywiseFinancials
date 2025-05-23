WITH
  -- 1. Combine all relevant transaction dates for each plan.
  --    This CTE gathers transaction dates from both plans_plan (for plan creation/initial activity)
  --    and savings_savingsaccount (for specific savings transactions).
  all_plan_transactions AS (
    -- Transactions from plans_plan (assuming created_at is an activity date for the plan itself)
    SELECT
      id AS plan_id,
      created_on AS transaction_date
    FROM plans_plan

    UNION ALL

    -- Transactions from savings_savingsaccount (assuming these are individual transactions for savings plans)
    -- IMPORTANT: This assumes savings_savingsaccount has a 'plan_id' column that links to plans_plan.id.
    SELECT
      plan_id,
      created_on AS transaction_date
    FROM savings_savingsaccount
  ),
  -- 2. Find the latest transaction date for each unique plan_id.
  --    This CTE aggregates the transaction dates from the previous CTE to determine
  --    the most recent activity for every plan.
  last_transaction_per_plan AS (
    SELECT
      plan_id,
      MAX(transaction_date) AS last_transaction_date
    FROM all_plan_transactions
    GROUP BY
      plan_id
  ),
  -- 3. Identify inactive plans by comparing the last transaction date to the current date.
  --    This CTE calculates the number of days since the last transaction for each plan
  --    and filters for plans that have been inactive for more than 365 days.
  inactive_plans_data AS (
    SELECT
  ltp.plan_id,
  p.owner_id,
  CASE
    WHEN p.is_regular_savings = 1 THEN 'Savings'
    WHEN p.is_a_fund = 1 THEN 'Investment'
    ELSE 'Other'
  END AS type,
  ltp.last_transaction_date,
  DATEDIFF(CURDATE(), ltp.last_transaction_date) AS inactivity_days
FROM last_transaction_per_plan AS ltp
JOIN plans_plan AS p
  ON ltp.plan_id = p.id
WHERE DATEDIFF(CURDATE(), ltp.last_transaction_date) > 365
  )
-- 4. Final selection and ordering of the results.
SELECT
  plan_id,
  owner_id,
  type,
  last_transaction_date,
  inactivity_days
FROM inactive_plans_data
ORDER BY
  inactivity_days DESC; -- Order by inactivity to see the longest inactive accounts first
