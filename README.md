# CASE STUDY: Smart Device Fitness Data
---

(insert index here)




## Background

Sleepr is a manufacturer of wellness-related smart appliances, with the "DreamSmrt" Smart Mattress as their flagship product.  Founded in 2014, Sleepr has secured a large marketshare position for sleep related smart devices, and has been considering branching out to other wellness related products.  One such product is a bracelet-style wellness tracker, similar to FitBit, and Sleepr is hoping an analysis of proxied market data might inform its future marketing campaigns.

---
## Overview of Project

Using proxied data from 33 Fitbit users who voluntarily uploaded their usage and wellness data, we will attempt to find correlations between various levels of physical activity and the amount of restful sleep those users enjoyed.

Our process for analyzing the data was as follows:

- Extract, tranform and load (ETL) data with Python and PostgreSQL

- Perform statistical testing and visualize data with R in RStudio

- Aggregate findings and visualizations into a Tableau story for presentation to stakeholders


## Resources

- Data: FitBit Fitness Tracker Data(https://www.kaggle.com/datasets/arashnic/fitbit)
- Software/Languages: Python 3.9.12 (Pandas Library), PostgreSQL 14, pgAdmin 4 v6.1, R w/ RStudio 2022.07.1 Build 554, Tableau Desktop 2022.2.1


## ETL Process and Database Design

Our dataset contains 15 CSV files, obtained from https://www.kaggle.com/datasets/arashnic/fitbit.  The data, which was automatically collected by FitBit devices and voluntarily submitted for aggregation, should be considered fairly reliable due to the automated nature of its sensory collection.


That being said, the data has certain limitations:

- Though there are 33 unique user ids in the data, only 24 of them wore their wellness trackers during the night, which means we can only use data from those users to track sleep patterns and correlations to other collected data.  We won't be able to rely on a standard T test to measure statistical signifance of our datapoints, since we don't have enough data to exceed the central limit theorum threshold.

- One file, which contained data relating to the users' weight, contained only 8 unique IDs, and much of the data in that file was manually entered rather than being collected by the sensors in their FitBit devices.  For these reasons, that file cannot be considered reliable and its data was omitted entirely from our analysis.

### Data Cleaning

- Upon inspection, many of the CSV files used non-uniform date-time formats, which would prove problematic when trying to import the files into a SQL database.  To correct this, I decided to use the Pandas library in Python to perform our initial data cleaning.  Here is an example of the script that was ran on each file:

(data cleaning screenshot)

- Looking through our various files, I saw that the only completely shared data that could be used to build a relational database (apart from the timestamps) were the unique user IDs, but none of the files contained those IDs as unique values (which could be used as Primary Keys within the SQL database).  For this purpose, I created a seperate file with only unique User IDS that I could use as a master key to unify the data files.

- I created a local PostgreSQL database to house the data with the following schema:

(schema screenshot)

- Once all files had been successfully imported to the SQL database, I started joining tables with similar time measurements with SQL queries:

(query join screenshot)


### Analyzing the Data in R

Before loading the dataset into R, the following R packages were installed/loaded:

```{r Loading Packages}
library(tidyverse)
library(dplyr)
library(gridExtra)
library(ggplot2)
library(ggpmisc)
```

After checking for null values in the newly joined/exported CSV File, I imported the file into RStudio and double-checked the number of unique user IDs that were left after the SQL inner join.  24 confirmed unique IDs remained.

(distinct user ids screenshot)

To obtain a broad-scale look at the range of the combined dataset, I generated summary statistics for each of the dataset's features:

(summary statistics screenshot)


### Incorrect Assumptions and Ambiguous Trendlines

The first plot I generated with R turned out to be based on a mistaken assumption: That there would be a correlation between the number of calories burned in the day and the amount of sleep the user enjoyed at night.  As you can see in the scatterplot below, that assumption turned out to be wholly incorrect.

(calories burned screenshot)

The second plot sought to find a correlation between the amount of sedentary minutes of each day (the time spent by users sitting and doing nothing the physically exert themselves, presumably in front of a screen) and the amount of sleep they achieved.  While the chart suggested that there could be a relationship between the two features, the plot's trendline appeared somewhat ambiguous.  


(sedentary minutes plot curved trendline)

Inspecting the points in the scatter plot, there appeared to be a number of extreme outlier values.

## Identifying Outliers in the Data

Since it appeared that there could possibly be a relationship between the users' sedentary periods and the amount of sleep they got, I decided to remove extreme outliers in the data (possibly caused by the users removing their trackers without disabling them) and regenerate the plot.

The first step was creating boxplots to verify that there were actually outliers in the data:

(sleep boxplot screenshot)

(sedentary boxplot screenshot)

The plots confirmed quite a few outlier datapoints, which would throw off our trendline analysis.  Using the Q1/3 +- 1.5 * IQR (Inter-Quartile Range) formula to define the bounds of the data to be included in the plot, I wrote the following code to remove outliers and subsequently generate a cleaned version of the scatterplot:

```{r Identifying and Removing Outliers}
iqr <- IQR(activity$totalminutesasleep)
Q <-quantile(activity$totalminutesasleep, probs=c(.25, .75), na.rm = FALSE)
upper <- Q[2]+1.5*iqr
lower <- Q[1]-1.5*iqr
cleaned_sleep_minutes <- subset(activity, activity$totalminutesasleep > lower & activity$totalminutesasleep < upper)
iqr2 <- IQR(cleaned_sleep_minutes$sedentaryminutes)
Q2 <- quantile(cleaned_sleep_minutes$sedentaryminutes, probs=c(.25, .75), na.rm = FALSE)
upper2 <- Q2[2]+1.5*iqr2
lower2 <- Q2[1]-1.5*iqr2
cleaned_sedsleep_minutes <- subset(cleaned_sleep_minutes, cleaned_sleep_minutes$sedentaryminutes > lower2 & cleaned_sleep_minutes$sedentaryminutes < upper2)
```

## Analyzing Cleaned Data

(sedentary vs sleep cleaned screenshot)

Since the dataset included features for several levels of activity intensity (Lightly Active, Fairly Active, and Very Active), I performed the same cleaning process on those datapoints and generated comparable plots.

(lightly active cleaned screenshot)

As you can see in the screenshot above, not every data feature produced meaningful correlation.  For comparison, I produced a chart lattice to compare the four data visualizations:

(Chart lattice screenshot)

When looking at the various levels of activity intensities, compared to the number of minutes of sleep the users enjoyed on those particular recording dates, the only factor that stood out was the number of minutes spent in a sedentary state.

