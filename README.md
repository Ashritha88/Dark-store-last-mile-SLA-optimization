# Dark Store & Last-Mile SLA Optimization

Data-driven analysis of dark-store and last-mile fulfillment operations using SQL, Microsoft Excel, DMAIC, Pareto analysis, and root-cause analysis.

---

## 📌 Project Overview

This project focuses on analyzing order-level fulfillment data in a quick-commerce environment to evaluate SLA performance and identify the major operational factors contributing to delivery delays.

The objective is to convert operational data into actionable insights that can help improve fulfillment speed, reliability, and overall customer experience.

---

## 🎯 Objectives

- Analyze overall SLA compliance and delivery performance.
- Compare fulfillment performance across different stores.
- Identify differences between peak and non-peak operating periods.
- Identify the major causes of SLA breaches.
- Use Pareto and Fishbone analysis for root-cause identification.
- Develop data-driven recommendations for operational improvement.

---

## 🛠️ Tools & Methodologies

- **SQL / MySQL** – Data extraction, filtering, aggregation, and KPI analysis
- **Microsoft Excel** – Data cleaning, analysis, pivot tables, and visualization
- **DMAIC** – Define, Measure, Analyze, Improve, Control
- **Pareto Analysis** – Identification of major delay contributors
- **Fishbone Analysis** – Root-cause analysis
- **Lean Methodology** – Process improvement and waste reduction

---

## 📊 Key Analysis

### 1. SLA Performance Analysis

Calculated and analyzed key fulfillment metrics including:

- Total orders
- On-time orders
- SLA breaches
- SLA compliance percentage
- Average delivery time
- Store-level performance

### 2. Peak vs Non-Peak Analysis

Compared operational performance during peak and non-peak periods to identify the effect of demand concentration on SLA compliance and fulfillment delays.

### 3. Store-Level Analysis

Evaluated individual fulfillment centers/stores to identify locations with relatively higher SLA breach rates and operational inefficiencies.

### 4. Pareto Root-Cause Analysis

Applied Pareto analysis to identify the small number of operational factors responsible for a large proportion of SLA breaches.

### 5. Fishbone Analysis

Used a Fishbone diagram to categorize potential root causes across areas such as:

- Manpower
- Process
- Inventory
- Picking
- Packing
- Dispatch
- Technology
- External factors

---

## 💡 Key Insights

The analysis highlights how fulfillment performance can be affected by:

- Peak-hour demand pressure
- Manpower availability
- Picking and packing delays
- SKU placement and picking efficiency
- Dispatch waiting time
- Inventory availability
- Store-level operational differences

---

## 🚀 Improvement Recommendations

Based on the analysis, the following operational improvements were identified:

- Optimize manpower allocation during peak-demand periods.
- Improve SKU placement to reduce picking time.
- Reduce unnecessary waiting between picking, packing, and dispatch.
- Monitor store-level SLA performance using operational KPIs.
- Improve availability of fast-moving products.
- Use root-cause analysis regularly to identify recurring fulfillment bottlenecks.

---

## 📁 Repository Structure

```text
Dark-store-last-mile-SLA-optimization/
│
├── README.md
│
├── data/
│   ├── dark_store_master.csv
│   └── dark_store_orders.csv
│
├── excel/
│   └── Excel analysis files
│
└── sql/
    └── SQL analysis queries

