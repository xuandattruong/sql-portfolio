database: AdventureWorks
data source: https://drive.google.com/file/d/1AzhEfmHAMFCVoHBJd0_ccBrivA1ZD3Tf/view

-- Looking at data of all three years

	select * from sales_2015
	union
	select * from sales_2016 
	union 
	select * from sales_2017

-- Display total number of orders in three years by product key, using a sub-query

	select sales.ProductKey, sales.TerritoryKey, sum(sales.OrderQuantity) as TotalOrderQuantity
	from
		(
		select * from sales_2015
		union
		select * from sales_2016 
		union 
		select * from sales_2017
		) as sales
	group by 1, 2
	
-- Display products in 2016 and 2017 that was returned, using a join syntax
	select a.ProductKey, sum(a.OrderQuantity), sum(b.ReturnQuantity)
	from
		(
		select * from sales_2016
		union
		select * from sales_2017 
		) 
		as s
		left join `returns`  as r
		on a.ProductKey = b.ProductKey
	group by a.ProductKey
	order by 3 desc
	
-- Caculate the return rate by product category in three years, using a common table expression

	with 
		total_sales as
			(
			select * from sales_2015 
			union 
			select * from sales_2016 
			union 
			select * from sales_2017 
			)
	select pc.CategoryName, sum(s.OrderQuantity) as OrderQuantity, sum(r.ReturnQuantity) as ReturnQuantity, 
		concat(sum(r.ReturnQuantity)/sum(s.OrderQuantity)*100, '%') as ReturnRate
	from 
		total_sales as s
		left join products as p 
		on s.ProductKey = p.ProductKey 
		left join product_subcategories as ps 
		on p.ProductSubcategoryKey = ps.ProductSubcategoryKey 
		left join product_categories as pc 
		on ps.ProductCategoryKey = pc.ProductCategoryKey 
		left join `returns`  as r 
		on s.ProductKey = r.ProductKey 
	group by 1

-- Find the products that the return rate in 2017 was higher than that in 2016

	with 
		return_2016 as 
			(
			select s.ProductKey, sum(ReturnQuantity)/sum(OrderQuantity) as ReturnRate
			from sales_2016 as s
			left join `returns` as r 
			on s.ProductKey = r.ProductKey 
			group by 1
			),
		return_2017 as 
			(
			select s.ProductKey, sum(ReturnQuantity)/sum(OrderQuantity) as ReturnRate
			from sales_2017 as s
			left join `returns` as r 
			on s.ProductKey = r.ProductKey 
			group by 1
			)
	select r16.ProductKey, r16.ReturnRate as ReturnRate2016, r17.ReturnRate as ReturnRate2017
	from return_2016 as r16
		left join return_2017 as r17
		on r16.ProductKey = r17.ProductKey
	where r16.ReturnRate < r17.ReturnRate
	
-- Display return rate in 2017 of products having sold quantity in 2017 higher than average number of 2016 products

	select s.ProductKey, sum(r.ReturnQuantity)/sum(s.OrderQuantity) as ReturnRate2017
	from sales_2017 as s
		left join returns as r 
		on s.ProductKey = r.ProductKey 
	where s.OrderQuantity >
		(
		select avg(OrderQuantity) 
		from sales_2016
		)
	group by 1
