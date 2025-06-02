# 📊 Northwind Advanced Sales Analytics with PostgreSQL

This project is a practice-based Data Analytics case study using the **Northwind** sample database to apply advanced **PostgreSQL** techniques, focusing on **summary statistics**, **window functions**, and **business intelligence queries**.

---

## 🚀 Project Objective

To derive **actionable business insights** from sales, customer behavior, and employee performance data using advanced SQL skills such as:

- Window Functions (e.g., `RANK()`, `LAG()`, `LEAD()`, `PERCENTILE_CONT()`)
- Aggregate Functions (e.g., `SUM()`, `AVG()`, `COUNT()`)
- Time-based analysis (e.g., `DATE_TRUNC()`, `AGE()`)
- Ranking, Cohort, and Performance Analysis

---

## 🧰 Tech Stack

- **Database**: PostgreSQL
- **SQL Client**: PgAdmin 4
- **Dataset**: Northwind Sample Database
- **Tools Used**: GitHub for version control and documentation

---

## 📌 Key Analyses & Insights

### 1. 🏅 Top Products per Category
- Identified the top 3 best-selling products in each product category using `RANK()` and `PARTITION BY`.

### 2. 📈 Monthly Sales Trends
- Analyzed monthly revenue performance with `DATE_TRUNC()` and calculated MoM changes and cumulative sums.

### 3. 👨‍💼 Employee Sales Rankings
- Ranked employees by total sales and compared each one to the team average using window aggregates.

### 4. 🛒 Customer Lifetime Value (CLV)
- Calculated total revenue per customer, first and latest order dates, and active durations.

### 5. ⏱ Order Delivery Time Analysis
- Measured average delivery durations and flagged orders exceeding the 75th percentile using `PERCENTILE_CONT`.

### 6. 🔁 Repeat Customer Rate
- Identified customers with multiple purchases and calculated repeat customer percentages per country.

### 7. 📦 Inventory Turnover Ratio
- Calculated how fast each product is sold in relation to available stock using join and ratio logic.

### 8. 📊 Customer Cohort Analysis (Bonus)
- Grouped customers by first purchase month and tracked engagement over time using custom cohort logic.

---

## 📚 Learning Outcome

This project reinforced:
- Practical knowledge of **window functions** in PostgreSQL
- Ability to write **analytical SQL queries** for business insights
- Confidence in using **PgAdmin** for real-world analysis
- Better understanding of **BI concepts** like CLV, inventory metrics, and employee performance KPIs

---

## 📬 Contact

For any questions or feedback, feel free to connect with me on [LinkedIn]([https://www.linkedin.com](https://www.linkedin.com/in/cemozcel%C4%B1k/)) or open an issue in this repository!
