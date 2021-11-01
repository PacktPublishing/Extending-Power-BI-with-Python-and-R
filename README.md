# 	Extending Power BI with Python and R

<a href="https://www.packtpub.com/product/extending-power-bi-with-python-and-r/9781801078207"><img src="https://static.packt-cdn.com/products/9781801078207/cover/smaller" alt="Extending Power BI with Python and R" height="256px" align="right"></a>

This is the code repository for [Extending Power BI with Python and R](https://www.packtpub.com/product/extending-power-bi-with-python-and-r/9781801078207), published by Packt.

**Ingest, transform, enrich, and visualize data using the power of analytical languages**

## What is this book about?

Python and R allow you to extend Power BI capabilities to simplify ingestion and transformation activities, enhance dashboards, and highlight insights. With this book, you'll be able to make your artifacts far more interesting and rich in insights using analytical languages.

You'll start by learning how to configure your Power BI environment to use your Python and R scripts. The book then explores data ingestion and data transformation extensions, and advances to focus on data augmentation and data visualization. You'll understand how to import data from external sources and transform them using complex algorithms. The book helps you implement personal data de-identification methods such as pseudonymization, anonymization, and masking in Power BI. You'll be able to call external APIs to enrich your data much more quickly using Python programming and R programming. Later, you'll learn advanced Python and R techniques to perform in-depth analysis and extract valuable information using statistics and machine learning. You'll also understand the main statistical features of datasets by plotting multiple visual graphs in the process of creating a machine learning model.

By the end of this book, you’ll be able to enrich your Power BI data models and visualizations using complex algorithms in Python and R.

This book covers the following exciting features: 
* Discover best practices for using Python and R in Power BI products
* Use Python and R to perform complex data manipulations in Power BI
* Apply data anonymization and data pseudonymization in Power BI
* Log data and load large datasets in Power BI using Python and R
* Enrich your Power BI dashboards using external APIs and machine learning models
* Extract insights from your data using linear optimization and other algorithms
* Handle outliers and missing values for multivariate and time-series data
* Create any visualization, as complex as you want, using R scripts

If you feel this book is for you, get your [copy](https://www.amazon.com/Extending-Power-Python-transform-analytical-ebook/dp/B09CQ5G53Y/ref=sr_1_1?crid=23ZIHDLXFV8KJ&dchild=1&keywords=extending+power+bi+with+python+and+r&qid=1635751617&sprefix=Extending+Power%2Caps%2C363&sr=8-1) today!

<a href="https://www.packtpub.com/product/extending-power-bi-with-python-and-r/9781801078207"><img src="https://raw.githubusercontent.com/PacktPublishing/GitHub/master/GitHub.png" alt="https://www.packtpub.com/" border="5" /></a>

## Instructions and Navigations
All of the code is organized into folders.

The code will look like the following:

```
tbl <- src_tbl %>%
  mutate(
    across(categorical_vars, as.factor),
    across(integer_vars, as.integer)
  ) %>%
  select( -all_of(vars_to_drop) )
  
```
**Following is what you need for this book:**
This book is for business analysts, business intelligence professionals, and data scientists who already use Microsoft Power BI and want to add more value to their analysis using Python and R. Working knowledge of Power BI is required to make the most of this book. Basic knowledge of Python and R will also be helpful.

With the following software and hardware list you can run all code files present in the book (Chapter 1-16).

| Chapter  | Software required                                                                    | OS required                        |
| -------- | -------------------------------------------------------------------------------------| -----------------------------------|
|  	1-16	   |   	Power BI Desktop and Power BI Gateway                                			  | Windows(Any) | 		
|  	1-16	   |   	Rstudio and VS Code                                			       | Windows(Any) | 

We also provide a PDF file that has color images of the screenshots/diagrams used in this book. [Click here to download it](http://www.packtpub.com/sites/default/files/downloads/9781801078207_ColorImages.pdf).

### Related products <Other books you may enjoy>
* AWS Penetration Testing [[Packt]](https://www.packtpub.com/product/aws-penetration-testing/9781839216923) [[Amazon]](https://www.amazon.com/AWS-Penetration-Testing-Beginners-Metasploit/dp/1839216921/ref=sr_1_1?dchild=1&keywords=AWS+Penetration+Testing&qid=1635752706&sr=8-1)
  
* Learn Kali Linux 2019 [[Packt]](https://www.packtpub.com/free-ebook/learn-kali-linux-2019/9781789611809) [[Amazon]](https://www.amazon.com/Learn-Kali-Linux-2018-hands/dp/1789611806/ref=sr_1_1?dchild=1&keywords=Learn+Kali+Linux+2019&qid=1635752810&sr=8-1)


  
## Get to Know the Author
**Luca Zavarella** is certified as an Azure Data Scientist Associate and is also a Microsoft MVP for artificial intelligence. He graduated in computer engineering at the Faculty of Engineering of L'Aquila University, and he has more than 10 years of experience working on the Microsoft Data Platform. He started his journey as a T-SQL developer on SQL Server 2000 and 2005. He then focused on all the Microsoft Business Intelligence stack (SSIS, SSAS, SSRS), deepening data warehousing techniques. Recently, he has been dedicating himself to the world of advanced analytics and data science. He also graduated with honors in classical piano at the Conservatory "Alfredo Casella" in L'Aquila.
