# Stock_Market_Analysis_Mysql_Project

## Overview

This project demonstrates how to analyze Indian stock market data using SQL. The dataset (`national_stock`) includes details such as stock symbols, last traded price (LTP), turnover, volume, percentage changes, and 52-week highs/lows.

The queries are designed to practice a wide range of SQL concepts, from basic retrievals to advanced self-joins, while providing insights into real-world market behavior. Each query is explained with its purpose so that the reasoning is clear.

---

## Dataset Setup

1. Create a database:

```sql
CREATE DATABASE stock_market;
USE stock_market;
```

2. Import the CSV file using MySQL Workbench:

   * Right-click on the database
   * Use Table Data Import Wizard
   * Map the CSV file to create the `national_stock` table

Once imported, queries can be executed directly on this table.

---

## Queries & Explanations

### Basic Queries (DQL – SELECT)

**List all stock symbols and LTP**

```sql
SELECT Symbol, LTP FROM national_stock;
```

Why: Gives a quick view of stocks and their latest prices.

**Top 10 stocks with highest trading volume**

```sql
SELECT * FROM national_stock ORDER BY `Volume (lacs)` DESC LIMIT 10;
```

Why: Identifies most actively traded stocks.

**Classify stocks as gainers or losers**

```sql
SELECT Symbol, `% Chng`,
    CASE WHEN `% Chng` >= 0 THEN 'Gainer' ELSE 'Loser' END AS stock_change
FROM national_stock;
```

Why: Helps separate winners and losers in the market.

**Company with the highest turnover**

```sql
SELECT Symbol, `Turnover (crs.)`
FROM national_stock
WHERE `Turnover (crs.)` = (SELECT MAX(`Turnover (crs.)`) FROM national_stock);
```

Why: Finds the company contributing most to market value.

**Companies where LTP > Open**

```sql
SELECT Symbol, LTP FROM national_stock WHERE LTP > Open;
```

Why: Highlights intraday gainers.

---

### Aggregations & Grouping

**Average daily change across all stocks**

```sql
SELECT AVG(Chng) AS average_daily_change FROM national_stock;
```

Why: Shows overall market sentiment.

**Total market turnover**

```sql
SELECT SUM(`Turnover (crs.)`) AS total_turnover FROM national_stock;
```

Why: Measures market-wide money flow.

**Average traded volume**

```sql
SELECT AVG(`Volume (lacs)`) AS average_volume_traded FROM national_stock;
```

Why: Determines typical stock liquidity.

**Stocks with maximum and minimum 365-day % change**

```sql
SELECT Symbol, `365 d % chng`
FROM national_stock
WHERE `365 d % chng` = (SELECT MAX(`365 d % chng`) FROM national_stock)
   OR `365 d % chng` = (SELECT MIN(`365 d % chng`) FROM national_stock);
```

Why: Finds long-term best and worst performers.

**Rank stocks by 30-day % change**

```sql
SELECT Symbol, `30 d % chng` FROM national_stock ORDER BY `30 d % chng` DESC;
```

Why: Identifies top short-term movers.

**Companies with volume > 5x average volume**

```sql
SELECT Symbol, `Volume (lacs)`
FROM national_stock
WHERE `Volume (lacs)` > 5 * (SELECT AVG(`Volume (lacs)`) FROM national_stock);
```

Why: Detects unusual trading activity.

**Average LTP of top 20 companies by turnover**

```sql
SELECT AVG(LTP) AS average_ltp
FROM (
    SELECT LTP, `Turnover (crs.)`
    FROM national_stock
    ORDER BY `Turnover (crs.)` DESC
    LIMIT 20
) AS top_20_traded;
```

Why: Finds average price of highly traded companies.

**Company with maximum 52w high-low difference (most volatile)**

```sql
SELECT Symbol, `52w H`, `52w L`, (`52w H` - `52w L`) AS difference_52w
FROM national_stock
ORDER BY difference_52w DESC
LIMIT 1;
```

Why: Detects stocks with the widest price swings.

---

### Advanced Queries

**Top 10 companies with highest 365-day % change**

```sql
SELECT *
FROM national_stock
ORDER BY `365 d % chng` DESC
LIMIT 10;
```

Why: Finds top long-term gainers.

**Bottom 10 companies by 30-day % change**

```sql
SELECT *
FROM national_stock
ORDER BY `30 d % chng` ASC
LIMIT 10;
```

Why: Highlights short-term losers.

**Companies at 52-week high**

```sql
SELECT Symbol, LTP, `52w H`
FROM national_stock
WHERE LTP = `52w H`;
```

Why: Breakout analysis.

**Companies at 52-week low**

```sql
SELECT Symbol, LTP, `52w L`
FROM national_stock
WHERE LTP = `52w L`;
```

Why: Finds beaten-down stocks.

**Short-term recovery stocks (30d positive, 365d negative)**

```sql
SELECT Symbol, `30 d % chng`, `365 d % chng`
FROM national_stock
WHERE `30 d % chng` >= 0
  AND `365 d % chng` <= 0;
```

Why: Detects stocks bouncing back.

**Company with highest average daily turnover per unit volume**

```sql
SELECT Symbol, AVG(`Turnover (crs.)` / `Volume (lacs)`) AS avg_turnover_per_unit
FROM national_stock
GROUP BY Symbol
ORDER BY avg_turnover_per_unit DESC
LIMIT 1;
```

Why: Finds high-value trades per unit.

**Data inconsistency check: Chng > 0 but % Chng < 0**

```sql
SELECT Symbol, Chng, `% Chng`
FROM national_stock
WHERE Chng > 0
  AND `% Chng` < 0;
```

Why: Detects possible data errors.

**Stocks gaining >10% in 30 days but down in 365 days**

```sql
SELECT Symbol, `30 d % chng`, `365 d % chng`
FROM national_stock
WHERE `30 d % chng` > 10
  AND `365 d % chng` < 0;
```

Why: Finds turnaround opportunities.

**% difference between LTP and 52-week high**

```sql
SELECT Symbol, LTP, `52w H`,
       ROUND(((LTP - `52w H`) / `52w H`) * 100, 2) AS diff_LTP_52wH
FROM national_stock;
```

Why: Tracks proximity to 52-week highs.

**% difference between LTP and 52-week low**

```sql
SELECT Symbol, LTP, `52w L`,
       ROUND(((LTP - `52w L`) / `52w L`) * 100, 2) AS diff_LTP_52wL
FROM national_stock;
```

Why: Tracks proximity to 52-week lows.

---

### Self-Join Queries

**Pairs of stocks whose LTPs are within 5% of each other**

```sql
SELECT a.Symbol AS stock_A, b.Symbol AS stock_B, a.LTP AS LTP_A, b.LTP AS LTP_B,
       ROUND((ABS(a.LTP - b.LTP) / a.LTP) * 100, 2) AS difference_percent
FROM national_stock a
JOIN national_stock b ON a.Symbol < b.Symbol
WHERE ABS(a.LTP - b.LTP) <= 0.05 * a.LTP;
```

Why: Compares similarly priced stocks.

**Pairs where one is a gainer and the other a loser**

```sql
SELECT a.Symbol AS stock_A, b.Symbol AS stock_B, a.`% Chng` AS gainer, b.`% Chng` AS loser
FROM national_stock a
JOIN national_stock b ON a.Symbol < b.Symbol
WHERE a.`% Chng` > 0 AND b.`% Chng` < 0;
```

Why: Useful for hedging strategies.

**Stock pairs: higher volume but lower turnover**

```sql
SELECT a.Symbol AS stock_A, b.Symbol AS stock_B,
       a.`Volume (lacs)` AS Volume_A, a.`Turnover (crs.)` AS Turnover_A,
       b.`Volume (lacs)` AS Volume_B, b.`Turnover (crs.)` AS Turnover_B
FROM national_stock a
JOIN national_stock b ON a.Symbol < b.Symbol
WHERE a.`Volume (lacs)` > b.`Volume (lacs)` AND a.`Turnover (crs.)` < b.`Turnover (crs.)`;
```

Why: Finds inefficient trading patterns.

**Stock pairs trading within 10% of their 52-week high**

```sql
SELECT a.Symbol AS stock_A, b.Symbol AS stock_B, a.LTP AS LTP_A, a.`52w H` AS high_A,
       b.LTP AS LTP_B, b.`52w H` AS high_B
FROM national_stock a
JOIN national_stock b ON a.Symbol < b.Symbol
WHERE a.LTP >= a.`52w H` - 0.10 * a.`52w H`
  AND b.LTP >= b.`52w H` - 0.10 * b.`52w H`;
```

Why: Detects momentum pairs.

**Stock pairs where value traded of one is at least double the other**

```sql
SELECT a.Symbol AS stock_A, b.Symbol AS stock_B, a.LTP * a.`Volume (lacs)` AS Value_A,
       b.LTP * b.`Volume (lacs)` AS Value_B
FROM national_stock a
JOIN national_stock b ON a.Symbol < b.Symbol
WHERE a.LTP * a.`Volume (lacs)` >= 2 * b.LTP * b.`Volume (lacs)`
   OR b.LTP * b.`Volume (lacs)` >= 2 * a.LTP * a.`Volume (lacs)`;
```

Why: Finds dominance in pair trades.

---

## Key Insights

* Identify top gainers and losers in short-term and long-term
* Detect stocks near 52-week highs or lows
* Spot unusual trading activity or market anomalies
* Compare stock pairs for trading strategies and momentum
* Evaluate market trends using turnover, volume, and volatility

---

## Tech Stack

* MySQL
* SQL (DQL, Aggregations, Joins, CASE, Self Joins)
* CSV Dataset (`national_stock`)

---
