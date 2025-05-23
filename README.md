# CowrywiseFinancials
This is a project done using Cowrywise Data for a recruitment project

SQL Query Solutions: Customer Analytics Scenarios
This README details the SQL-based solutions for four distinct customer analytics scenarios. Each section provides an explanation of the approach taken and highlights challenges encountered during the queries.

Table of Contents
- Customer Cross-Selling Opportunity

- Customer Transaction Frequency Analysis

- Account Inactivity Alert

- Customer Lifetime Value (CLV) Estimation

1. Customer Cross-Selling Opportunity
Scenario: Identify customers who have both a savings and an investment plan (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

Explanation of Approach
By using two Common Table Expressions (CTEs) to first identify customers with funded savings plans and then customers with funded investment plans.

savings_plans CTE: This CTE joins users_customuser with plans_plan to count funded savings plans (is_regular_savings = 1 and status = 'Funded') and sum their deposit_amount for each customer.

investment_plans CTE:  This CTE joins users_customuser with plans_plan to count funded investment plans (is_a_fund = 1 and status = 'Funded') for each customer.

Final SELECT: A JOIN operation on owner_id between these two CTEs identifies customers who appear in both sets. A WHERE clause ensuring that both savings_count and investment_count are greater than zero. The results are then ordered by total_savings_deposits in descending order.

Challenges
Initial Table Ambiguity: The initial problem statement implied savings_savingsaccount for savings plans. However, a clarification indicated that is_regular_savings = 1 and is_a_fund = 1 flags were available in the plans_plan table.

Resolution: The CTEs were refactored to exclusively use the plans_plan table for both savings and investment plan identification, simplifying the joins and ensuring consistency with the provided flags. The SUM(p.deposit_amount) was correctly applied to the plans_plan table for total deposits.

2. Customer Transaction Frequency Analysis
Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
Task: Calculate the average number of transactions per customer per month and categorize them: "High Frequency" (≥10 transactions/month), "Medium Frequency" (3-9 transactions/month), "Low Frequency" (≤2 transactions/month).

Explanation of Approach
This query used three CTEs to break down the calculation:

customer_transactions_monthly CTE: This CTE counts the total transactions for each customer within each month. DATE_TRUNC('month', s.created_at) is used to group transactions by the start of the month.

customer_average_transactions CTE: This CTE takes the monthly transaction counts and calculates the AVG(transaction_count) for each customer across all months they had transactions.

customer_categories CTE: This CTE applies the categorization logic using a CASE statement based on the avg_transactions_per_month calculated in the previous CTE.

Final SELECT: The final query groups the results by frequency_category and counts the customer_ids in each category, also providing the overall AVG(avg_transactions_per_month) for each category.

Challenges
Date Truncation: Ensuring accurate grouping by month (DATE_TRUNC) is crucial for calculating monthly averages. The specific function can vary slightly between SQL dialects.

Multi-level Aggregation: The need to first aggregate transactions by month per customer, then average those monthly counts per customer, and finally aggregate customers by category required careful layering of CTEs.

Resolution: The use of DATE_TRUNC('month', ...) (or equivalent) in the first CTE correctly grouped transactions. The subsequent CTEs built upon this foundation, allowing for the correct calculation of average monthly transactions and subsequent categorization.

3. Account Inactivity Alert
Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).

Explanation of Approach
This solution used three CTEs to identify inactive accounts:

all_plan_transactions CTE: This CTE combines all relevant transaction dates. It includes created_at from plans_plan (representing plan creation or initial activity) and created_at from savings_savingsaccount (representing individual savings transactions). A UNION ALL is used to merge these dates.

last_transaction_per_plan CTE: This CTE finds the MAX(transaction_date) for each plan_id from the combined transaction dates, giving the latest activity for every plan.

inactive_plans_data CTE: This CTE joins the latest transaction dates back to plans_plan to get owner_id and determine the type of plan. It calculates inactivity_days by finding the difference between the current date and the last_transaction_date. A WHERE clause filters for plans with inactivity_days greater than 365.

Final SELECT: Selects the required columns and orders by inactivity_days descending.

Challenges
Combining Transaction Sources: Transactions could originate from plans_plan (e.g., plan creation date) or savings_savingsaccount (e.g., individual deposits). Combining these into a single stream of activity dates was key.

savings_savingsaccount Linkage: A critical assumption was made that savings_savingsaccount has a plan_id column to directly link transactions to specific plans. If this assumption is incorrect, the query for savings transactions would need to be re-designed (e.g., by linking via owner_id and then inferring the associated plan).

Database-Specific Date Functions: Calculating the difference in days between two dates (CURRENT_DATE() and last_transaction_date) varies significantly across SQL dialects (e.g., DATEDIFF in MySQL/SQL Server).

Resolution: The UNION ALL effectively combined transaction sources. The assumption about savings_savingsaccount.plan_id was explicitly stated for clarity. The date difference calculation was provided with a generic example, noting the need for dialect-specific adjustment.

4. Customer Lifetime Value (CLV) Estimation
Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate: Account tenure (months since signup), Total transactions, Estimated CLV. Order by estimated CLV from highest to lowest.

Explanation of Approach
I used two CTEs to calculate the components for CLV:

customer_tenure CTE: Calculates the tenure_months for each customer using TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()). GREATEST(1, ...) is used to ensure tenure is at least 1 month to avoid division by zero.

customer_transactions_summary CTE: Summarizes total_transactions and total_profit (calculated as deposit * 0.001) for each customer from the savings_savingsaccount table.

Final SELECT: A LEFT JOIN combines the tenure and transaction summaries. COALESCE is used to handle customers with no transactions (setting counts/profits to 0). The estimated_clv is calculated using the formula (total_profit / tenure_months) * 12, and the result is rounded to two decimal places. The final output is ordered by estimated_clv in descending order.

Challenges
Division by Zero for New Customers: Customers who signed up very recently might have a tenure_months of 0, leading to a division by zero error in the CLV calculation.

Handling Customers with No Transactions: LEFT JOIN is necessary to include all customers, but those without transactions would have NULL values for total_transactions and total_profit, which would propagate to estimated_clv.

Resolution: GREATEST(1, TIMESTAMPDIFF(...)) was used to ensure tenure_months is always at least 1. COALESCE(value, 0) was applied to total_transactions and total_profit to convert NULLs to 0, allowing the CLV calculation to proceed correctly for all customers.
