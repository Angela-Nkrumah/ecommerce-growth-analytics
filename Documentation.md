# E-Commerce Growth Analytics: An SQL analysis of an e-commerce business.

## Table of Contents
1. [Project Overview](#1-project-overview)
   
2. [Business Context](#2-business-context)
   
3. [Dataset Description](#3-dataset-description)
   
4. [Tools Used](#4-tools-used)
   
5. [Data Cleaning](#5-data-cleaning)
   
6. [Exploratory Data Analysis](#6-exploratory-data-analysis)
   
7. [Growth Analytics](#7-growth-analytics)
 
8. [Key Findings & Business Recommendations](#8-key-findings--business-recommendations)
   
9. [Limitations](#9-limitations)
   
10. [Conclusion](#10-conclusion)



## 1. Project Overview
**Objective:**
This is a growth analysis project of an e-commerce business designed to analyse customer growth, revenue trends, 
purchase behaviour, and product performance using SQL while delivering actionable business recommendations without reliance on a dashboard.
The use of only SQL in this project was due to the fact that not every business question requires a dashboard. This project demonstrates the ability to extract, 
clean, and analyse data entirely through SQL, producing insights through structured query logic and written interpretation.


## 2. Business Context
**Business Type:** E-commerce retail platform
**Data Period:** 2024–2025
**Key Business Questions:**
1. How is revenue growing month on month?
2. Which customer segments are driving growth?
3. Where are we losing customers in the purchase funnel?
4. Which product categories are growing vs declining?
5. What is the relationship between customer reviews and sales?
6. Which cities are showing the strongest customer acquisition growth?


## 3. Dataset Description
**Source:** Kaggle** 
Note:This is a synthetic dataset generated  for analytical purposes. All names, emails, 
and personal details are fictitious.


**Tables:**

| Table | Rows | Description |
|-------|------|-------------|
| users.csv | ~10,000 | Customer profiles and demographics |
| products.csv | ~2,000 | Product catalog with pricing and ratings |
| orders.csv | ~20,000 | Order level transactions |
| order_items.csv | ~60,000 | Items purchased per order |
| reviews.csv | ~15,000 | Customer product reviews |
| events.csv | ~80,000 | User behaviour logs |

**Entity Relationship:**
- users → orders (via user_id)
- orders → order_items (via order_id)
- order_items → products (via product_id)
- users → reviews (via user_id)
- users → events (via user_id)


## 4. Tools Used
- **SQL (MySQL):** Data cleaning, transformation 
  and analysis
- **GitHub:** Version control and documentation


## 5. Data Cleaning

### 5.1 Initial Data Assessment
Six tables were created in MySQL to match the structure of each CSV file before importing: users, products, orders, order_items, reviews, and events. Column data types were assigned based on initial inspection of each CSV file.

### 5.2 Handling Missing Values
No nulls or missing values were found in the event_id column as well as the order_id column.
No null values in the orders table

### 5.3 Removing Duplicates
In the order_items table, The original query combined order_id, product_id, and quantity columns to check for duplicate entries, which is common in e-commerce order-item tables. Including the quantity column helped identify true duplicates versus separate entries of the same product with different amounts. These duplicates were not deleted; instead, they can be aggregated for cleaner analysis.

### 5.4 Standardising Column Names
In the users table,  proper case formatting was applied to ensure all customer names follow consistent capitalisation. This was done using CONCAT, UPPER and SUBSTRING functions. 
All text columns were checked for leading and trailing whitespace. No trimming was required beyond the name column.

### 5.5 Data Type Corrections
No post-import data type corrections were required as all columns were imported with their intended formats.

### 5.6 Handling Outliers
Initial statistical exploration of product pricing using average and standard deviation revealed a high level of dispersion, indicating the presence of extreme values. The large standard deviation relative to the mean suggested that the dataset contained both very low-priced and very high-priced products. Rather than treating these as immediate anomalies, further analysis was conducted to determine whether these values were data errors or legitimate contributors to business performance.
To understand this, products were segmented by total revenue and by units sold with corresponding average prices. The results showed that many of the top revenue-generating products achieved their performance through high pricing despite relatively low sales volumes, confirming the presence of premium tier products. Also, high-volume products were often lower-priced and did not necessarily contribute the most revenue. A notable exception was identified in a product, (Product: P000803)  that combined both high volume (50 units sold) and a high average price (953), highlighting a rare “star product” capable of driving both scale and profitability.
Based on these findings, the extreme values were determined to be valid and strategically important rather than noise. Removing them would distort revenue insights and underrepresent business performance. Instead, the appropriate approach is to segment these outliers (premium products) from standard products, analyze them separately to avoid skewed averages, and leverage them strategically in pricing and marketing decisions. This ensures that insights remain both statistically sound and aligned with real business dynamics.

### 5.7 Derived Columns
The following columns were added during the cleaning and preparation phase: 
 brand (products table): Added to capture brand information per product for deeper segmentation analysis.
user_id (order_items table): Added to enable direct customer level analysis at the item level without requiring an additional join through orders.
item_total (order_items table): Derived as item_price × quantity to capture total value per line item, avoiding repeated calculation in analysis queries


## 6. Exploratory Data Analysis

The dataset consists of 10,000 customers, with a very balanced gender distribution across the base. Customers categorized as “other” account for 3,419 (34.19%), followed closely by female customers at 3,334 (33.34%) and male customers at 3,247 (32.47%). This near-even split suggests that the business does not rely heavily on a single gender segment, which is a strong position for broad market appeal. Customers are also spread across a wide range of cities, indicating a geographically diverse customer base rather than dependence on a single location, which supports scalability and reduces regional risk. From a revenue perspective, focusing strictly on completed orders, the business generated a total of $2,419,712.58 from 4,021 orders, made by 3,320 unique customers. This shows a solid conversion from users to paying customers. 
However, it is important to note that completed orders represent only 20.11% of all orders placed. The remaining orders are split across returned, cancelled, shipped, and processing statuses, highlighting a significant gap between orders placed and revenue actually realized. The average order value ($601.77) gives a clear picture of typical customer spend, but the wide range between the minimum order value ($1.11) and maximum order value ($6,360.11) highlights significant variability in purchasing behavior. This suggests the presence of both low-value and high-value transactions, which may indicate different customer segments or the influence of higher-priced products driving overall revenue. Looking at the product landscape, the catalog is evenly distributed across categories, with most categories containing between 180 and 213 products, showing no heavy concentration in a single category. Pricing, however, varies significantly across categories. Electronics ($852.42) and automotive ($418.49) stand out as high-ticket categories, while Groceries ($16.60) and Books ($44.43) represent lower-cost, everyday purchase items. Despite these pricing differences, average product ratings remain relatively consistent across all categories, generally ranging between 3.62 and 3.72, suggesting stable customer satisfaction regardless of product type or price point. Overall, the data reflects a business with a diverse customer base, varied purchasing behavior, and a well-balanced product offering across multiple price segments.

### 6.1 Customer Overview
The customer base was first analyzed by breaking it down across gender to understand how users are distributed on the platform. This was done by counting the total number of customers in each gender category and calculating their percentage share of the overall user base, providing both scale and proportion for clearer interpretation.
From the results, the distribution is almost evenly split across all three groups. Customers categorized as “Other” make up the largest share at 34.19% (3,419 users), followed closely by female customers at 33.34% (3,334 users) and male customers at 32.47% (3,247 users). The differences between the groups are minimal, indicating that no single gender segment dominates the platform. This even distribution was cross referenced with revenue data in section 7.2 to determine whether spending behaviour differs significantly across gender segments.
From a business perspective, this suggests a well-balanced and diverse customer base, meaning the platform’s appeal is not skewed toward any particular gender. This is a strong position to be in, as it allows the business to design products, marketing strategies, and user experiences without needing to overly focus on one dominant segment. Instead, efforts can be spread more evenly or tailored inclusively to maintain engagement across all groups.

### 6.2 Revenue Overview
To get a clear picture of overall revenue performance, completed orders were analyzed to capture total transaction volume, customer participation, and the distribution of order values. For the revenue overview, total revenue was calculated using only completed orders, resulting in $2.42M. This reflects actual realized revenue, money the business has successfully earned
From the results, the business generated a total of $2.42M in revenue across 4,021 orders, with 3,320 unique customers making at least one purchase. This indicates a relatively broad customer base contributing to revenue, rather than heavy reliance on a small group of buyers. The average order value sits at 601.77, giving a sense of what a typical transaction looks like. Looking deeper at order values, there is a wide range between the minimum order (1.11) and the maximum order (6,360.11). This spread suggests a mix of low-value and high-value purchases, meaning customer spending behavior is quite varied. Business-wise, this could indicate opportunities for segmentation, for example, identifying high-value customers for retention strategies, while also understanding what drives smaller transactions and how to potentially increase their basket size.

### 6.3 Product Overview
The product catalog is well-balanced across categories, with no single category dominating in volume. Pricing varies widely. Electronics and automotive are high-ticket categories, while groceries and books are low-cost, high-frequency segments. Despite these differences, customer ratings are consistent across all categories (around 3.6 –  3.7), indicating stable product satisfaction. 
From a business perspective, this indicates a well-balanced catalog in both variety and perceived quality, but also highlights clear differences in revenue potential. Higher-priced categories likely drive larger transaction values, while lower-priced categories may rely more on volume. This creates an opportunity to tailor strategies differently, focusing on conversion and upselling in high-ticket categories, while driving frequency and repeat purchases in lower-cost ones.

### 6.4 Order Status Overview
To understand how order value is distributed across different stages of the order lifecycle, orders were grouped by status and analyzed based on both their volume and contribution to total revenue. This provides visibility into how much business is being completed successfully versus how much is tied up in cancellations, returns, or ongoing processes.
From the results, orders are almost evenly distributed across all statuses, each contributing roughly 19 – 21% of total orders and revenue. At first glance, this might look balanced, but in reality, it highlights a major operational concern. Only 20.11% of orders are marked as “completed”, meaning the majority of orders are either still in progress, cancelled, returned, or just shipped without confirmation of completion.
What stands out even more is the high volume and value of returned and cancelled orders, which together account for nearly 40% of total orders and revenue. This suggests that a significant portion of potential revenue is not being successfully realized. For example, returned orders alone contribute over $2.42M in value. It's important to note that, when analyzing order value by status, revenue was broken down across all order statuses, including shipped, returned, cancelled, and processing. At first glance, this creates a confusing situation where returned orders appear to contribute $2.42M in revenue, the same magnitude as completed orders.
This does not mean returned orders generated real revenue. Instead, it reflects the transaction value before the return occurred. In other words, the dataset records the full order amount regardless of whether the order was eventually refunded or cancelled. As a result, revenue in the order status analysis should be interpreted as gross order value, not net revenue.
From a business perspective, this distinction is critical. While completed orders represent actual earnings, returned and cancelled orders highlight potential revenue leakage. The fact that returned orders carry nearly the same value as completed ones suggests a significant risk area. It means that, for every dollar the company makes, it loses it again. This could point to issues such as product quality mismatches, inaccurate descriptions, poor customer experience, or logistical challenges


## 7. Growth Analytics

### 7.1 Month on Month Revenue Growth
The business shows highly volatile month-on-month revenue performance, with sharp increases followed by noticeable declines rather than a steady growth pattern. For example, revenue surged significantly in March 2024 (+83.54%) and again in April 2025 (+40.39%), but these gains are often followed by drops in the following months such as April 2024 (-23.01%) and March 2025 (-25.42%). This alternating pattern suggests that revenue is being driven by short-term factors like promotions, campaigns, or seasonal spikes rather than consistent customer demand or stable repeat purchasing behavior.
A major concern is the significant decline in November 2025 (-36.64%), which represents the steepest drop in the period and signals a potential operational or demand issue. Overall, the lack of consistent upward momentum indicates that the business may struggle with revenue predictability, making it difficult to plan inventory, marketing spend, and cash flow effectively. Addressing customer retention and smoothing out demand fluctuations would be critical to achieving more stable and sustainable growth

### 7.2 Customer Acquisition and Segmentation Analysis
Revenue growth is primarily driven by newly activated customers, who contribute 57% of total revenue across all genders. These customers also exhibit strong average order values, indicating high-quality acquisition. However, the relatively lower contribution from regular customers and the absence of a significant loyal segment suggest weak long-term retention, highlighting an opportunity to improve customer lifecycle strategies and repeat purchase behavior.

### 7.3 Purchase Funnel Analysis (where the business is losing customers in the purchasing funnel)
After structuring the funnel to reflect how users actually behave, the analysis focused on three key stages: view, cart, and purchase. Out of 9,961 users who viewed products, only 5,208 went on to add items to their cart, meaning nearly half (47.72%) dropped off before showing real buying intent. The bigger issue appears at the final stage, where only 1,326 users completed a purchase from the 5,208 who had already added items to cart, resulting in a sharp 74.54% drop-off. This means that while users are interested enough to consider buying, something is stopping them from completing the transaction. The problem is less about attracting customers and more about converting them at checkout, making this the most critical point of revenue loss in the funnel.

### 7.4 Product Category Growth
This product category growth  analysis shows one thing very clearly. Most product categories are not moving in a smooth “growth” direction; rather  they’re volatile. An example is  automotive and electronics. Based on findings,they generate some of the highest revenues, but they swing hard month-to-month (e.g., automotive drops -42% in Aug 2024, then jumps +63% the next month; Electronics spikes +161% then crashes -39%). This means revenue in these categories is likely driven by events such as: promotions, stock availability, or seasonal demand and not consistent customer demand. From a business standpoint, these are high-impact but unstable categories. 
On the other hand categories like beauty and home & kitchen, are a bit more stable but still inconsistent. Beauty shows periods of steady growth (mid–2025 especially), but ends with a sharp -53% drop, while home & kitchen grows in clusters but suffers repeated declines after peaks. These are the “almost there” categories. They have demand, but something is breaking momentum. That usually points to issues like weak repeat purchase behavior, inconsistent product availability, or poor customer retention after initial spikes.
Finally, categories like books, toys, and groceries tell a different story. Low revenue and no clear upward trend. They grow occasionally, but the declines are just as frequent and often more severe (e.g., Toys dropping -45%, Groceries -62%). These are not currently strong growth drivers for the business. At best, they’re niche; at worst, they’re draining attention and resources. 

### 7.5 Geographic Growth Analysis
To identify which cities are driving customer acquisition growth, the analysis tracked new user signups by city over time and measured both total customer volume and month-on-month growth. To avoid misleading results from very small sample sizes, a minimum threshold was applied so that only cities with a meaningful number of customers were considered. This ensures that the growth observed reflects real momentum rather than inflated percentages from low starting points.
From the results, New Michael (40% growth), Lake John (25%), and Michaelmouth (21.43%) stand out as the strongest growth markets. While their total customer counts are still relatively modest (9–10 customers), the consistency and pace of growth suggest these cities are gaining traction and represent early-stage expansion opportunities. Just behind them are cities like West Jennifer, West Michael, and North Michael, which show steady growth between 16–20% alongside slightly higher customer bases. These markets appear more stable and can be seen as reliable contributors to ongoing acquisition.
On the other hand, several cities show zero or negative growth, such as East Michael and New Robert (-8.33%), indicating that customer acquisition has either stalled or started to decline. Although these cities still have a baseline number of users, the lack of momentum shows that current acquisition strategies may no longer be effective in those areas. Overall, the analysis highlights a clear distinction between emerging high-growth cities worth investing in and more saturated or declining markets that may require a different strategic approach.

### 7.6 Review vs Sales Analysis
To understand the relationship between customer reviews and sales, products were first grouped into rating tiers based on their average review scores. Products with ratings of 4.5 and above were classified as “Excellent”, 3.5 – 4.49 as “Good”, 2.5 – 3.49 as “Average”, and anything below 2.5 as “Poor”. This made it easier to move beyond individual product noise and evaluate performance at a more meaningful, grouped level.
Once grouped, the expectation was straightforward. Higher-rated products should drive more sales. However, the results didn’t follow that pattern. Products in the “excellent” tier, despite having the highest average rating (4.66), contributed the least to total revenue ($13.5k) and had lower average units sold (5.48). This suggests these products are appreciated by customers but are not widely purchased, pointing more to limited visibility or reach than any issue with quality.
Meanwhile, the “good” and “average” tiers are doing the heavy lifting in terms of revenue, contributing $1.4M and $948k respectively. What stands out is that these products don’t have outstanding ratings, yet they consistently sell more units. This indicates that customer purchase decisions in this business are not strongly driven by reviews alone, but likely influenced more by factors like pricing, demand, or product availability. The most concerning finding is within the “poor” tier, where low-rated products (avg 2.22) still generate the highest average revenue per product (2211.50). This suggests customers are buying products they are not satisfied with, which may boost short-term revenue but poses a risk to long-term customer trust and retention.


## 8. Key Findings & Business Recommendations

###  Revenue is being driven by spikes but not stability
 Revenue growth is highly volatile, with sharp increases followed by equally sharp declines. This pattern shows that growth is being driven by short-term triggers (promotions, campaigns, seasonal demand) rather than consistent customer behavior. This has a negative effect on the business’s chance of being able to predict revenue which is often dangerous for planning, marketing spend, and cash flow.
Recommendation:
 Shift focus from campaign-driven sales to retention-driven revenue to increase customer lifetime value. This can be achieved by introducing:
Email/SMS remarketing flows.
Personalized product recommendations.
Subscription or repeat purchase incentives (especially for groceries, beauty).
Track repeat purchase rate as a core KPI, not just revenue


### Customers are being acquired well, but the business keeps failing to keep them.
 New customers contribute 57% of total revenue, while loyal customers barely exist as a meaningful segment. The business is spending resources to acquire customers, but seem not to be able to convert them into long-term value. This becomes expensive and unsustainable.

Recommendation:
Build a customer lifecycle strategy. This can be achieved by giving onboarding offers on first purchases, incentives (discount, bundle) on second purchases, and loyalty reward on third purchases.
Introduce:
Loyalty programs
Retargeting ads for past buyers
Post-purchase engagement (email, reviews, upsell)
This will help solve the leaky bucket problem of the business whereby customers come in, spend once and leave.


### To further solve the issue of a leaky bucket, the biggest revenue leak is at checkout (not traffic).

Customers seem to be interested in products, they even show intent , but something stops them from completing the purchase. This is evident by the  47.7% drop from view to cart and the 
massive 74.5% drop from cart to purchase. This can be the business’single biggest growth opportunity.

Recommendation:
Audit checkout experience:
Are there hidden costs (shipping, taxes)?
Is checkout too long or complex?
Are payment options limited?
Add:
Guest checkout
Multiple payment methods
Trust signals (reviews, guarantees)
Implement:
Cart abandonment emails
Exit-intent offers.
Fixing this alone can increase revenue without acquiring a single new customer.


### A huge amount of revenue is being lost through cancellation and returns.

A massive portion of potential revenue is being lost after customers have already decided to buy. Returned + cancelled orders is 40% of total order value. This is not a marketing problem, rather an operational and product problem.

Recommendation:
Investigate root causes by asking ans answering these questions.
What are the product quality issues?
Are there any misleading descriptions/images?
What are the causes for delivery delays?
When those questions are answered, fix them with:
Better product pages (clear specs, real images)
Size guides (for clothing)
Customer reviews displayed prominently
Track:
Return rate by product/category
Without fixing these problems, scaling marketing will just scale losses.


### The product strategy of the business seems to be unfocused (some categories are carrying the business, others are dragging it).

Not all categories deserve equal attention, but right now, they’re being treated that way. Electronics and automotive products are currently highly volatile. Beauty, kitchen and home are moderate but also unstable. Toys, books and grocery products are currently weak performers.

Recommendation:
Strong e-commerce businesses don’t try to win everywhere; rather they focus where margins and demand are strongest. To achieve this for the business,
Double down on high-performing categories. This can be done by ensuring stock availability and running target promotions.
Fix “almost there” categories by improving retention through bundles and subscriptions.
Re-evaluate weak categories by reducing inventory or repositioning them.


### Customer reviews are not driving sales but they are exposing risks. 
“Excellent” products are recording low sales,“good/average” products are actually recording the highest revenue. “Poor” products are still generating high revenue. The current pattern suggests customers may not be aware of product ratings before purchasing, or ratings are not prominently displayed. 

Recommendation:
In as much as “poor” are still generating high revenue, Selling low-rated products may boost short-term revenue, but it kills trust and retention long-term. In other to fix the problem with the various tier products;
Increase visibility of high-rated products by featuring them on the homepage and use a top rated section.
Fix low-rated products by improving quality or remove them if that is not possible.
Encourage reviews by using a post-purchase prompt and incentives feedback.
Making ratings more visible at the point of decision could shift purchasing behaviour toward higher quality products over time.


### Geographic growth is early-stage and under-leveraged
Cities like New Michael, Lake John, Michaelmouth show strong growth but low total customers. The business  has early traction markets which are not yet saturated.
Recommendation:
For an e-commerce business to successfully expand, traction needs to be identified early and scale aggressively on it. In order to achieve this in these locations:
Double down on these cities by introducing and promoting localized ads, faster delivery options and city-specific promotions.
For stagnant cities, re-evaluate marketing channels and test new acquisition strategies.


## 9. Limitations
- Dataset is synthetic and may not reflect 
  real world business complexity
- City level geography only. A regional or 
  country level would enable broader market analysis


## 10. Conclusion

This analysis set out to understand the growth health of an e-commerce business across six key dimensions: revenue trends, customer segments, purchase funnel behaviour, product category 
performance, geographic expansion, and the relationship between reviews and sales.
The central finding is that this business has a growth problem disguised as a revenue problem. On the surface, $2.42M in completed revenue and 10,000 registered customers suggest a functioning business. But beneath those numbers lies a pattern of leakage at every stage of the customer journey from the 74.54% of cart users who never complete a purchase, to the 40% of order value lost through returns and cancellations, to the near-absence of loyal repeat customers in a base dominated by one-time buyers.
The volatility in month-on-month revenue further confirms that the business is currently dependent on short-term spikes rather than compounding 
growth. Until the business addresses retention, checkout conversion, and operational quality simultaneously, scaling acquisition will only scale losses.
The most actionable opportunity identified is checkout optimization. Fixing cart abandonment 
alone without acquiring a single new customer could materially increase revenue by converting existing intent into completed transactions. Combined with a structured customer lifecycle 
strategy and category portfolio focus, the business has a clear path from volatile, spike-driven 
performance to sustainable, predictable growth.

This analysis was conducted entirely in SQL, demonstrating that meaningful business intelligence does not always require a dashboard. A structured querying and rigorous interpretation can surface insights that drive strategic decisions at the highest level.
