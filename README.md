# E-Commerce Sales Analysis

An end-to-end data analytics project exploring e-commerce sales,
profitability, customer activity, product performance, discounts,
delivery status, and product returns using **Python, SQL Server, and
Power BI**.

## Project Overview

The goal of this project is to transform raw e-commerce datasets into
useful business insights. The work includes data inspection and
cleaning, data-quality checks, SQL-based analysis, financial
reconciliation, and an interactive Power BI dashboard.

## Tools & Technologies

-   **Python:** Pandas
-   **SQL:** Microsoft SQL Server
-   **BI & Visualization:** Power BI
-   **DAX:** Measures and calculated columns

## Dataset

The project uses five CSV datasets:

  -----------------------------------------------------------------------------------
  Dataset                                         Purpose
  ----------------------------------------------- -----------------------------------
  `customer_master.csv`                           Customer information

  `ecommerce_sales_customer_analytics_150k.csv`   E-commerce transactions, customer
                                                  activity, delivery, returns, and
                                                  financial metrics

  `order_items.csv`                               Product-level order line items

  `product_catalog.csv`                           Product details and categories

  `dataset_statistics.csv`                        Dataset-level statistics
  -----------------------------------------------------------------------------------

> **Note:** The CSV source files are not included in this repository
> unless separately added. Update the file paths in the notebook to
> match your local dataset location.

## Project Workflow

### 1. Python --- Data Cleaning & Exploration

The Jupyter Notebook (`E-Commerce Sales Analysis.ipynb`) covers:

-   Loading the five CSV datasets with Pandas.
-   Reviewing dataset dimensions, columns, data types, and sample
    records.
-   Checking missing values and duplicate records.
-   Reviewing return-status and return-reason missing values and filling
    them with `Not Returned` where appropriate.
-   Filling missing campaign names and coupon codes with `No Campaign`
    and `No Coupon`.
-   Converting order date and order time fields to datetime types.
-   Exploring descriptive statistics for customer, quantity, and
    financial fields.
-   Checking for negative or invalid values in financial fields,
    quantity, and customer age.
-   Rounding discount percentage values for inspection.

### 2. SQL Server --- Data Validation & Business Analysis

The SQL script (`ECommerce_Analysis.sql`) contains queries for:

-   Row counts, duplicate checks, and table-grain investigation.
-   Validation of quantity, unit price, discounts, gross sales, net
    sales, tax, shipping cost, product cost, and profit.
-   Discount percentage distribution and calculation checks.
-   Order-level aggregation and comparison of `orders` and `ecomm`
    financial values.
-   Investigation of differences between product-level order items and
    transaction-level e-commerce records.
-   Customer analysis, including top customers by revenue, profit,
    profit margin, and order frequency.
-   Product analysis, including top and bottom products by revenue,
    profit, and profit margin.
-   Category-level revenue, profit, and return-rate analysis.
-   Profit analysis by delivery status, return status, campaign,
    customer rating, and review sentiment.
-   Monthly and yearly sales and profit trends.
-   Discount bucket analysis and profitability comparisons.

The script also builds intermediate temporary tables and a
`final_order_product` table for matched orders whose product-line totals
reconcile with the corresponding e-commerce transaction values.

### 3. Power BI --- Interactive Dashboard

The Power BI report (`ECommerce_Analysis.pbix`) presents the analysis
through dashboard pages and visuals, including:

-   Sales overview and key performance indicators.
-   Product and category performance.
-   Customer analysis.
-   Order and delivery analysis.
-   Discount category versus average profit.
-   Orders by time of day.

DAX calculations are used for measures and derived categories, including
discount percentage, discount category, order count, and order-time
category.

## Business Questions Explored

1.  Which product categories generate the highest revenue and profit?
2.  Which are the top five most profitable products?
3.  Which delivery statuses are associated with the highest and lowest
    profit?
4.  How do discounts relate to profit?
5.  Which regions generate the highest sales and profit?
6.  Which product categories have the highest return rates?
7.  At what time of day do customers place the most orders?

## Selected Findings

The following findings are based on the analyses performed during the
project:

-   **Regional performance:** South recorded the highest total sales
    (approximately 60.59 million) and total profit (approximately 23.34
    million) among the regions analyzed. North had the highest average
    profit per transaction row in the reported comparison.
-   **Discounts and profitability:** The no-discount group had the
    highest average profit (approximately 722.12), while the
    very-high-discount group had the lowest (approximately 310.94). The
    medium-discount group recorded the highest total profit in that
    analysis.
-   **Product returns:** Automotive had the highest observed category
    return rate (approximately 7.29%), while Beauty & Personal Care had
    the lowest (approximately 6.59%) among the categories shown.
-   **Order timing:** The night category had the highest order volume in
    the Power BI time-of-day visual, followed by morning, afternoon, and
    evening.
-   **Delivery status:** On Time had the highest total profit in the
    delivery-status comparison. Cancelled transactions also showed
    positive profit values, which were identified as an area requiring
    further data investigation.

## Data Quality & Reconciliation Notes

An important part of this project was investigating differences between
the `orders` and `ecomm` tables.

-   `orders` contains product-level rows, and an order can contain
    multiple product lines.
-   `ecomm` is analyzed at the transaction/order level.
-   Summing product-level values and comparing them directly with
    transaction-level values can produce misleading results if the
    grains are not aligned.
-   The SQL analysis identified financial mismatches between the two
    tables and investigated examples where the transaction-level values
    did not equal the sum of all product lines.
-   `final_order_product` was created from matched orders where the
    product-line net sales and profit totals reconciled with the
    corresponding `ecomm` values.

**Scope limitation:** Analyses using `final_order_product` represent the
matched subset of orders, not necessarily the complete dataset. Results
from this subset should not be presented as full-dataset totals without
further validation. Return-rate calculations based on expanded product
rows are product-row-level rates, not necessarily unique-order return
rates.

The findings describe associations and patterns in the available data.
For example, lower average profit in higher-discount groups does not by
itself prove that discounts caused the lower profit.

## Repository Structure

A suggested GitHub repository layout:

``` text
E-Commerce-Sales-Analysis/
│
├── E-Commerce Sales Analysis.ipynb
├── ECommerce_Analysis.sql
├── ECommerce_Analysis.pbix
├── README.md
│
└── data/                  # Add source CSV files here if permitted
    ├── customer_master.csv
    ├── ecommerce_sales_customer_analytics_150k.csv
    ├── order_items.csv
    ├── product_catalog.csv
    └── dataset_statistics.csv
```

## How to Use This Project

### Python Notebook

1.  Clone or download this repository.

2.  Install the required Python library:

    ``` bash
    pip install pandas jupyter
    ```

3.  Place the CSV files in your local dataset folder.

4.  Open `E-Commerce Sales Analysis.ipynb`.

5.  Update the CSV file paths in the first notebook cells to match your
    local paths.

6.  Run the notebook cells in order.

### SQL Server

1.  Open `ECommerce_Analysis.sql` in SQL Server Management Studio
    (SSMS).
2.  Import the source CSV data into SQL Server tables named `customer`,
    `ecomm`, `orders`, `product`, and `stat`.
3.  Review the database creation and table-renaming statements at the
    beginning of the script before running them.
4.  Execute the validation and analysis sections in sequence. Some later
    sections depend on temporary tables created earlier in the script.

### Power BI

1.  Open `ECommerce_Analysis.pbix` using Power BI Desktop.
2.  If prompted, update the data source paths or database connection to
    your local environment.
3.  Refresh the data model to load the available source data.

## Skills Demonstrated

-   Data cleaning and exploratory data analysis
-   Data quality checks and financial validation
-   SQL joins, CTEs, aggregations, CASE expressions, and window
    functions
-   Transaction-level and product-level data-grain analysis
-   DAX measures and calculated columns
-   Power BI dashboard development and data visualization
-   Business insight generation and analytical problem-solving

## Future Improvements

-   Complete and document reconciliation of all transaction-level and
    product-level financial differences.
-   Validate dashboard metrics against a clearly defined source of
    truth.
-   Add a date/calendar dimension and more detailed time-based trend
    analysis.
-   Compare return rates using both product-row and unique-order
    definitions.
-   Add automated data-quality checks and refresh documentation.

------------------------------------------------------------------------

**Project:** E-Commerce Sales Analysis\
**Author:** Santhosh R\
**Focus:** Data Analytics \| SQL Server \| Python \| Power BI
