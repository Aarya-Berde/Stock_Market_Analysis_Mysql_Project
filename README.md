# Stock_Market_Analysis_Mysql_Project
SQL queries for analyzing Indian stock market data. Includes basic retrievals, aggregations, ranking, and advanced self-join queries to explore trading patterns, gainers/losers, turnover, and volatility.


# 📊 Stock Market Analysis MySQL Project

## Overview
This project focuses on analyzing **Indian stock market data** using SQL. It demonstrates how to clean, organize, and query structured financial data to extract insights. The dataset includes fields like stock symbol, last traded price (LTP), volume, turnover, % change, and 52-week highs/lows. Queries are designed to replicate **real-world analysis tasks** such as ranking stocks, anomaly detection, and occasion/category/time-based grouping.

**📂 Data Import (CSV → Database)**

* The stock market dataset is provided in **CSV format**.
* Using **MySQL Workbench**, the CSV file is easily imported by:

  1. Right-clicking on the target database.
  2. Selecting **Table Data Import Wizard**.
  3. Choosing the CSV file and mapping columns.
* Once imported, the CSV data becomes a table (e.g., `national_stock`) ready for SQL queries.

---

**📝 Features & Scope**
The SQL scripts cover:

* Basic retrievals (SELECT, filtering, ordering)
* Aggregations (SUM, AVG, MAX, MIN, COUNT)
* Ranking & comparisons (top gainers, losers, 52-week range)
* Self-joins and advanced joins (pair analysis, consistency checks)
* Time, occasion, and category-based analysis
* Data validation & anomaly detection

---

## 🔍 Example Queries & Why They’re Used

**Q1: Find the stock with the highest turnover-to-volume ratio**

```sql
SELECT symbol, (`Turnover (crs.)` / `Volume (lacs)`) AS avg_turnover_per_unit
FROM national_stock
ORDER BY avg_turnover_per_unit DESC
LIMIT 1;
```

*Why?* → Identifies companies where each traded unit has high value, showing strong investor confidence.

**Q2: Find stocks within 5% of their 52-week high**

```sql
SELECT symbol, LTP, `52w H`
FROM national_stock
WHERE LTP >= 0.95 * `52w H`;
```

*Why?* → Helps track stocks that are close to their peak performance, useful for breakout analysis.

**Q3: Find the most volatile stocks**

```sql
SELECT symbol, (`52w H` - `52w L`) AS yearly_range
FROM national_stock
ORDER BY yearly_range DESC
LIMIT 5;
```

*Why?* → Shows which stocks fluctuate the most, helping with risk management decisions.

---

## 🕒 Occasion, Category & Time-Based Analysis

**Q4: Find average daily turnover by sector (Category-wise analysis)**

```sql
SELECT sector, AVG(`Turnover (crs.)`) AS avg_turnover
FROM national_stock
GROUP BY sector
ORDER BY avg_turnover DESC;
```

*Why?* → Reveals which categories (sectors) attract the most trading activity.

**Q5: Find stocks traded during a specific occasion (e.g., Diwali week)**

```sql
SELECT symbol, LTP, `Turnover (crs.)`
FROM national_stock
WHERE trade_date BETWEEN '2025-10-20' AND '2025-10-27';
```

*Why?* → Festival/occasion-based analysis shows how market sentiment changes during events like Diwali or Budget announcements.

**Q6: Find month-wise top performing stocks (Time-based analysis)**

```sql
SELECT MONTH(trade_date) AS trade_month, symbol,
       AVG(percent_change) AS avg_monthly_return
FROM national_stock
GROUP BY trade_month, symbol
ORDER BY trade_month, avg_monthly_return DESC;
```

*Why?* → Helps identify seasonal patterns and recurring trends in stock performance.

**🛠️ Technologies Used**

* **MySQL** (database engine)
* **SQL** (query language)
* **CSV dataset** (imported via MySQL Workbench)

**🚀 Usage**

1. Import the CSV into MySQL using **Table Data Import Wizard**.
2. Run queries from the `queries/` folder inside your MySQL client.
3. Analyze results to gain insights into stock performance, volatility, seasonal effects, and sector-based trends.
