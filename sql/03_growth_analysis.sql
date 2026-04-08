-- ================================================
-- E-Commerce Growth Analytics
-- File: 03_growth_analysis.sql
-- Purpose: Growth analysis
-- Author: Angela Nkrumah
-- Date: 2025
-- ================================================
-- month month revnue growth
with monthly_revenue as (
	Select 
       date_format(order_date, '%Y-%m-01') as month,
       sum(total_amount) as revenue
	from orders
    where order_status = 'completed'
    Group by date_format(order_date, '%Y-%m-01')
),
revenue_growth as (
   Select
      month,
      revenue,
      lag(revenue) over (order by month) as prev_month_revenue,
      round(
         (revenue - LAG(revenue) OVER (ORDER BY month)) 
            / LAG(revenue) OVER (ORDER BY month) * 100, 2
        ) AS mom_growth_pct
    FROM monthly_revenue
 )
select 
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(prev_month_revenue, 2) AS prev_month_revenue,
    mom_growth_pct,
    case 
        when mom_growth_pct > 0 then 'Growth'
        when mom_growth_pct < 0 then 'Decline'
        when mom_growth_pct = 0 then 'Flat'
        ELSE 'No Prior Month'
    end as trend
From revenue_growth
order by month;   
         
 -- customer segementation and acquisition driving growth
 with max_date as (
    select MAX(order_date) as dataset_max_date
    from orders
),
customer_revenue as (
    select 
        u.user_id,
        u.gender,
        u.city,
        
        case 
            when MIN(o.order_date) >= DATE_SUB(m.dataset_max_date, interval 90 day)
                then 'New Customer'
            when COUNT(distinct o.order_id) >= 3 
                then 'Loyal Customer'
            else 'Regular Customer'
        end as customer_segment,

        COUNT(distinct o.order_id) as total_orders,
        ROUND(SUM(o.total_amount), 2) as total_revenue,
        ROUND(avg(o.total_amount), 2) as avg_order_value

    from users u
    join orders o on u.user_id = o.user_id
    cross join max_date m   

    where o.order_status = 'Completed'
    group by u.user_id, u.gender, u.city, m.dataset_max_date
),
segment_summary as (
    select 
        customer_segment,
        gender,
        COUNT(distinct user_id) as customer_count,
        ROUND(SUM(total_revenue), 2) as segment_revenue,
        ROUND(avg(avg_order_value), 2) as avg_order_value,
        ROUND(SUM(total_revenue) / SUM(SUM(total_revenue)) 
            over() * 100, 2) as revenue_share_pct
    from customer_revenue
    group by customer_segment, gender
)
select *
from segment_summary
order by segment_revenue DESC;


-- Which geographic group is driving growth
with customer_revenue as (
    select 
        u.user_id,
        u.gender,
        u.city,
        case 
            when DATEDIFF(MAX(o.order_date), u.signup_date) <= 90 
                then 'New Customer'
            when COUNT(distinct o.order_id) >= 5 
                then 'Loyal Customer'
            else 'Regular Customer'
        end as customer_segment,
        COUNT(distinct o.order_id) as total_orders,
        ROUND(SUM(o.total_amount), 2) as total_revenue,
        ROUND(avg(o.total_amount), 2) as avg_order_value
    from users u
    join orders o on u.user_id = o.user_id
    where o.order_status = 'Completed'
    group by u.user_id, u.gender, u.city, u.signup_date
),
segment_summary as (
    select 
        customer_segment,
        gender,
        COUNT(distinct user_id) as customer_count,
        ROUND(SUM(total_revenue), 2) as segment_revenue,
        ROUND(avg(avg_order_value), 2) as avg_order_value,
        ROUND(SUM(total_revenue) / SUM(SUM(total_revenue)) 
            over() * 100, 2) as revenue_share_pct
    from customer_revenue
    group by customer_segment, gender
)
select *
from segment_summary
order by segment_revenue desc;

-- where are we losing revenue in the purchasing funnel
with user_journey as (
    select 
        user_id,
        MIN(case when event_type = 'view' then event_timestamp end) as view_time,
        MIN(case when event_type = 'cart' then event_timestamp end) as cart_time,
        MIN(case when event_type = 'purchase' then event_timestamp end) as purchase_time
    from events
    group by user_id
),

funnel_counts as (
    select 
        COUNT(case when view_time is not null then 1 end) as view_users,
        COUNT(case 
            when view_time is not null 
            and cart_time is not null 
            and cart_time > view_time 
        then 1 end) as cart_users,

        COUNT(case 
            when cart_time is not null 
            and purchase_time is not null 
            and purchase_time > cart_time 
        then 1 end) as purchase_users
    from user_journey
),

funnel_final as (
    select 1 as step, 'view' as event_type, view_users as users from funnel_counts
    union all
    select
    2, 'cart', cart_users from funnel_counts
    union all
    select 3, 'purchase', purchase_users FROM funnel_counts
)

select 
    step,
    event_type,
    users,
    lag(users) over (order by step) as prev_users,
    ROUND(users / lag(users) over (order by step) * 100, 2) as conversion_rate_pct,
    ROUND((1 - users / lag(users) over (order by step)) * 100, 2) as drop_off_pct
from funnel_final
order by step;

-- Product category growth
with category_monthly as (
    select 
        DATE_FORMAT(o.order_date, '%Y-%m-01') as month_date,
        DATE_FORMAT(o.order_date, '%b %Y') as month_label,
        p.category,
        ROUND(SUM(oi.item_price * oi.quantity), 2) as category_revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join products p on oi.product_id = p.product_id
    where o.order_status = 'Completed'
    group by month_date, month_label, p.category
),
category_growth as (
    select 
        month_date,
        month_label,
        category,
        category_revenue,
        lag(category_revenue) over (
            partition by category 
            order by month_date
        ) as prev_month_revenue,
        ROUND(
            (category_revenue - lag(category_revenue) over (
                partition by category order by month_date)
            ) / lag(category_revenue) over (
                partition by category order by month_date) * 100
        , 2) as mom_growth_pct
    from category_monthly
)
select
    month_date,
    month_label,
    category,
    category_revenue,
    prev_month_revenue,
    mom_growth_pct,
    case 
        when mom_growth_pct > 0 then 'Growing'
        when mom_growth_pct < 0 then 'Declining'
        when mom_growth_pct = 0 then 'Flat'
        else 'First Month'
    end as trend
from category_growth
order by category, month_date;


-- relationship between customer reviews and sales
with product_reviews as (
    select 
        product_id,
        ROUND(avg(rating), 2) as avg_rating,
        COUNT(*) as review_count
    from reviews
    group by product_id
),
product_sales as (
    select 
        oi.product_id,
        COUNT(distinct oi.order_id) as total_orders,
        SUM(oi.quantity) as units_sold,
        ROUND(SUM(oi.item_price * oi.quantity), 2) as total_revenue
    from order_items oi
    join orders o on oi.order_id = o.order_id
    where o.order_status = 'Completed'
	group by oi.product_id
),
combined as (
    select 
        p.product_id,
        p.product_name,
        p.category,
        pr.avg_rating,
        pr.review_count,
        ps.total_orders,
        ps.units_sold,
        ps.total_revenue,
        case 
            when pr.avg_rating >= 4.5 then 'Excellent'
            when pr.avg_rating >= 3.5 then 'Good'
            when pr.avg_rating >= 2.5 then 'Average'
            else 'Poor'
        end as rating_tier
    from products p
    left join product_reviews pr on p.product_id = pr.product_id
    left join product_sales ps on p.product_id = ps.product_id
)
select 
    rating_tier,
    COUNT(*) as product_count,
    ROUND(avg(avg_rating), 2) as avg_rating,
    ROUND(avg(units_sold), 2) as avg_units_sold,
    ROUND(avg(total_revenue), 2) as avg_revenue,
    ROUND(SUM(total_revenue), 2) as total_revenue
from combined
group by rating_tier
order by avg_rating desc;

-- Geographic growth analysis
with city_monthly_signups as (
    select 
        DATE_FORMAT(signup_date, '%Y-%m-01') as month_date,
        DATE_FORMAT(signup_date, '%b %Y') as month_label,
        city,
        COUNT(distinct user_id) as new_customers
    from users
    group by month_date, month_label, city
),
city_growth as (
    select 
        month_date,
        month_label,
        city,
        new_customers,
        SUM(new_customers) over (
            partition by city 
            order by month_date
        ) as cumulative_customers,
        lag(new_customers) over (
            partition by city 
            order by month_date
        ) as prev_month_customers,
        ROUND(
            (new_customers - lag(new_customers) over (
                partition by city order by month_date)
            ) / lag(new_customers) over (
                partition by city order by month_date) * 100
        , 2) as mom_growth_pct
    from city_monthly_signups
),
city_summary as (
    select 
        city,
        SUM(new_customers) as total_customers,
        ROUND(avg(mom_growth_pct), 2) as avg_monthly_growth_pct,
        MAX(new_customers) as peak_month_signups
    from city_growth
    group by city
)
select *
from city_summary
where total_customers >= 8   
order by avg_monthly_growth_pct desc;
