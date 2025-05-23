WITH
  -- 1. CTE to get savings account details from plans_plan
  savings_plans AS (
    SELECT
      u.id AS owner_id,
      CONCAT(u.first_name, " ", u.last_name) AS name,
      COUNT(p.id) AS savings_count,
      SUM(p.amount) AS total_savings_deposits -- Sum deposits from plans_plan
    FROM users_customuser AS u
    JOIN plans_plan AS p ON u.id = p.owner_id
    WHERE
      p.is_regular_savings = 1 
      AND p.amount > 0
    GROUP BY
      u.id,
      u.first_name, u.last_name
  ),
  -- 2. CTE to get investment plan details from plans_plan
  investment_plans AS (
    SELECT
      u.id AS owner_id,
      CONCAT(u.first_name, " ", u.last_name) AS name,
      COUNT(p.id) AS investment_count
    FROM users_customuser AS u
    JOIN plans_plan AS p ON u.id = p.owner_id
    WHERE
      p.is_a_fund = 1 -- Use is_a_fund
      AND p.amount > 0 
    GROUP BY
      u.id,
      u.first_name, u.last_name
  )
-- 3. Final SELECT to join and filter
SELECT
  sp.owner_id,
  sp.name,
  sp.savings_count,
  ip.investment_count,
  sp.total_savings_deposits AS total_deposits
FROM savings_plans AS sp
JOIN investment_plans AS ip ON sp.owner_id = ip.owner_id
WHERE
  sp.savings_count > 0
  AND ip.investment_count > 0
ORDER BY
  sp.total_savings_deposits DESC;
