# CASE STUDY: Smart Device Fitness Data
---

[Project Overview](#project-overview)

[Data Processing (ETL)](#etl-process-and-database-design)

[Cleaning and Visualizing Data with R](#analyzing-the-data-in-r)

[Analyzing Cleaned Data](#analyzing-cleaned-data)

[Summary and Conclusions](#summary)


![sleepr.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/Sleepr.png)

## Background

Sleepr is a manufacturer of wellness-related smart appliances, with the "DreamSmrt" Smart Mattress as their flagship product.  Founded in 2014, Sleepr has secured a large marketshare position for sleep related smart devices, and has been considering branching out to other wellness related products.  One such product is a bracelet-style wellness tracker, similar to FitBit, and Sleepr is hoping an analysis of proxied market data might inform its future marketing campaigns.

---
## Project Overview

Using proxied data from 33 Fitbit users who voluntarily uploaded their usage and wellness data, we will attempt to find correlations between various levels of physical activity and the amount of restful sleep those users enjoyed.  We will then translate any correlations found into marketing insights for the client.


Our process for analyzing the data was as follows:

- Extract, tranform and load (ETL) data with Python and PostgreSQL

- Perform statistical testing and visualize data with R in RStudio

- Aggregate findings and visualizations into a Tableau story for presentation to stakeholders


### Resources

- Data: [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit)
- Software/Languages: Python 3.9.12 (Pandas Library), PostgreSQL 14, pgAdmin 4 v6.1, R w/ RStudio 2022.07.1 Build 554, Tableau Desktop 2022.2.1

---

## ETL Process and Database Design

Our dataset contains 15 CSV files, obtained from [Kaggle](https://www.kaggle.com/datasets/arashnic/fitbit).  The data, which was automatically collected by FitBit devices and voluntarily submitted for aggregation, should be considered fairly reliable due to the automated nature of its sensory collection.  


That being said, the data has certain limitations:

- Though there are 33 unique user ids in the data, only 24 of them wore their wellness trackers during the night, which means we can only use data from those users to track sleep patterns and correlations to other collected data.  We won't be able to rely on a standard T test to measure statistical signifance of our datapoints, since we don't have enough data to exceed the central limit theorum threshold.  We can analyze the data to assess general trends, but ideally it would be better to have much more data.

- One file, which contained data relating to the users' weight, contained only 8 unique IDs, and much of the data in that file was manually entered rather than being collected by the sensors in their FitBit devices.  For these reasons, that file cannot be considered reliable and its data was ultimately omitted from our analysis.

- We don't have data on other important factors that may impact the users' sleep cycles.  A few of those factors might include age, chronic ailments or sleep disorders, and medications being taken by the users.

---

### Data Cleaning

Upon inspection, many of the CSV files used non-uniform date-time formats, which would prove problematic when trying to import the files into a SQL database.  To correct this, the Pandas library in Python was used to perform our initial data cleaning.  Here is an example of the script that was ran on each file:

![data_cleaning.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/data_cleaning.png)

Looking through our various files, it seemed that the only completely shared data that could be used to build a relational database (apart from the timestamps) were the unique user IDs, but none of the files contained those IDs as unique values (which could be used as Primary Keys within the SQL database).  For this purpose, a seperate file with only unique User IDS was generated, to use as a master key to unify the data files.

We created a local PostgreSQL database to house the data with the following [schema](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/schema.sql):

![schema_small.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/schema_small.png)

Once all files had been successfully imported to the SQL database, I started joining tables with similar time measurements with SQL queries:

![sql_query.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/sql_query.png)

---

## Analyzing the Data in R

Before loading the dataset into R, the following R packages were installed/loaded:

```{r Loading Packages}
library(tidyverse)
library(dplyr)
library(gridExtra)
library(ggplot2)
library(ggpmisc)
```

After checking for null values in the newly joined/exported CSV File, I imported the file into RStudio and double-checked the number of unique user IDs that were left after the SQL inner join.  24 confirmed unique IDs remained.

![distinct_ids.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/distinct_ids.png)

To obtain a broad-scale look at the range of the combined dataset, I generated summary statistics for each of the dataset's features:

```{r Summary Statistics}
activity %>% 
  select(totalsteps, totaldistance, sedentaryminutes, veryactiveminutes, fairlyactiveminutes, lightlyactiveminutes, calories, totalsleeprecords, totalminutesasleep, totaltimeinbed) %>% 
  summary()
```

![summary_statistics.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/summary_statistics.png)


### Inspecting Unclean Data

The first plot generated with R turned out to be based on a mistaken assumption: That there would be a correlation between the number of calories burned in the day and the amount of sleep the user enjoyed at night.  As you can see in the scatterplot below, that assumption turned out to be wholly incorrect.

![calories_vs_sleep_minutes.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/calories_vs_sleep_minutes.png)

The second plot sought to find a correlation between the amount of sedentary minutes of each day (the time spent by users sitting and doing nothing the physically exert themselves, presumably in front of a screen) and the amount of sleep they achieved.  While the chart suggested that there could be a relationship between the two features, the plot's trendline appeared somewhat ambiguous.  


![sedentary_minutes_vs_sleep_original.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/sedentary_minutes_vs_sleep_original.png)

Inspecting the points in the scatter plot, there appeared to be a number of extreme outlier values.

### Identifying Outliers in the Data

Since it appeared that there could possibly be a relationship between the users' sedentary periods and the amount of sleep they got, I decided to remove extreme outliers in the data (possibly caused by the users removing their trackers without disabling them) and regenerate the plot.

The first step was creating boxplots to verify that there were actually outliers in the data:

![sleep_boxplot.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/sleep_boxplot.png)

![sed_boxplot.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/sed_boxplot.png)

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

---

## Analyzing Cleaned Data

```{r Re-plot Sedentary Minutes vs. Minutes Asleep (Outliers Omitted)}
sed_plot <- ggplot(data=cleaned_sedsleep_minutes, aes(x=totalminutesasleep, y=sedentaryminutes)) +
  stat_poly_eq(label.x = "right", label.y = "top") +
  geom_point() + stat_smooth(method=lm) + labs(title = "Sedentary Minutes vs. Minutes Asleep") + 
  theme(plot.title = element_text(size=10))
sed_plot
```
![sedentary_minutes_vs_sleep_cleaned.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/sedentary_minutes_vs_sleep_cleaned.png)

Since the dataset included features for several levels of activity intensity (Lightly Active, Fairly Active, and Very Active), I performed the same cleaning process on those datapoints and generated comparable plots.

![light_activity_cleaned.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/light_activity_cleaned.png)

As you can see in the screenshot above, not every data feature produced meaningful correlation.  In the plot above, we see that the correlation trend line is almost flat, telling us that there is no meaningful relation between the amount of users' light activity during the day and how much sleep they attain at night.  For comparison, I produced a chart lattice to compare the four data visualizations:

![chart_lattice.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/chart_lattice.png)

When looking at the various levels of activity intensities, compared to the number of minutes of sleep the users enjoyed on those particular recording dates, the only factor that stood out was the number of minutes spent in a sedentary state.  A fairly significant negative correlation is visible between those two factors.  **This data suggests that the level of intensive activity isn't so much the driving factor behind getting more sleep, but rather the reduction of sedentary time**.  It's worth nothing that numerous "zero" values in the bottom two graphs are not null values, but simply represent days that specific users never exerted themselves past a "lightly active" level.

### **Most users are spending most of their time in a sedentary state**

Narrowing in on this factor, I decided to visualize what percentage of the users' average recorded activity was spent in a sedentary state.  The pie chart below, representing the average time spent in various levels of activity, was generated with the following R script (using data from the previous dataframes with outliers omitted):
```{r Activity Minutes by Type, echo=FALSE}
total_minutes <- (sum(cleaned_sedsleep_minutes$sedentaryminutes) + sum(cleaned_sedsleep_minutes$lightlyactiveminutes) + sum(cleaned_sedsleep_minutes$fairlyactiveminutes) + sum(cleaned_sedsleep_minutes$veryactiveminutes))
sedentary_percentage <- round((sum(cleaned_sedsleep_minutes$sedentaryminutes) / total_minutes) * 100, digits = 2)
lightly_percentage <- round((sum(cleaned_sedsleep_minutes$lightlyactiveminutes) / total_minutes) * 100, digits = 2)
fairly_percentage <- round((sum(cleaned_sedsleep_minutes$fairlyactiveminutes) / total_minutes) * 100, digits = 2)
very_percentage <- round((sum(cleaned_sedsleep_minutes$veryactiveminutes) / total_minutes) * 100, digits = 2)
percentages <- data.frame(level=c("Sedentary", "Lightly", "Fairly", "Very Active"), minutes = c(sedentary_percentage, lightly_percentage, fairly_percentage, very_percentage))
labels = c(sedentary_percentage, lightly_percentage, fairly_percentage, very_percentage)
ggplot(percentages, aes(x="", y=minutes, fill=level)) + geom_bar(stat="identity", width=1, color="white") + coord_polar("y", start=0) + theme_void() + labs(title="Percentage of Active Minutes")
```
![percentage_of_activity_minutes.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/percentage_of_activity_minutes.png)

(An interactive version of the chart, with more granular labeling, can be found below in the related Tableau Story)

As you can immediately see, most of the users are spending the majority (73.13%) of their time in a sedentary state.  Most users spend at least a small amount of time per day in a "lightly active" state, but very few achieve "fairly" or "very active" states, or at least not for very long.

### Strong negative correlation between sedentary minutes and sleep time

Let's take a look at the days of the week that users are spending the most time (on average) in a sedentary state, and compare them to the average amount of sleep recorded on those nights.  The following charts were created in Tableau, and are accessible in the [Tableau Story] at the end of the analysis.

![avg_sedentary_minutes_by_week_day.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/avg_sedentary_minutes_by_week_day.png)

![avg_sleep_by_week_day.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/avg_sleep_by_week_day.png)

The two bar charts, when compared, appear to reinforce the narrative that more sedentary time leads to less sleep.  On each day that we see an increased number of sedentary minutes, we see the number of minutes asleep fall.  We also see elevated periods of sedentary minutes from Monday to Friday of each week, suggesting that the majority of these sedentary minutes take place during the workday.

### Average level of activity by hour of week day

![avg_activity_by_weekday.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/avg_activity_by_weekday.png)

The heatmap shown above shows the average activity intensities among users, per hour of each week day (with darker colors representing hightened intensity levels).  There appear to be higher than average levels of activity on Wednesdays (after 5pm) and on Saturday afternoons.  We also see average activity levels staying much lower for longer periods on Saturday and Sunday mornings, suggesting that the users are sleeping in (or at least not rushing off to work).  This may also suggest that the hightened number of sleeping minutes we observed on Sundays may be in the morning, not the evening, and may correlate to reduced sedentary time on Saturdays. Though the heatmap shows higher-than-average levels of general activity on Tuesdays, our previous graphs show that Tuesdays account for some of the fewest number of sleeping minutes.  However, according to the heatmap, the users tend to stay up (and active) later on Tuesdays than they do on Saturdays, so the reduced hours of sleep may be deliberate.

---

## SUMMARY

[View the interactive Tableau story here](https://public.tableau.com/views/CASESTUDYSmartDeviceFitnessData/CASESTUDYSmartDeviceFitnessData?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

![dashboard.png](https://github.com/ZeroDarkHardy/CASE-STUDY-Smart-Device-Fitness-Data/blob/main/images/dashboard.png)

### Conclusions based on our analysis:

- The majority of the users' recorded time was spent in a sedentary state (73.13%, with outliers omitted).  The majority of those sedentary minutes take place during standard work hours from Monday through Friday of each week.
- On days when we observe higher than average amounts of time spent in hightened states of physical activity, we tend to observe more minutes of sleep that evening and the following morning.
- While some minor correlations are observed between the levels of physical activity and the amount of sleep minutes, the strongest (negative) correlation is found in the number of sedentary minutes.  This implies that its less important that the users achieve a high intensity of physical activity, and more important that they simply remain sedentary for less time.  This begs a question for future analysis (with more data): Is the act of being sedentary the driving factor hindering sleep, or is a specific ***sedentary*** activity causing it (for example, time staring at a screen with a harsh lighting profile).  There appears to be no correlation of any kind between the number of calories a user burns in a day vs the amount of sleep they get.

### Marketing recommendations to client:

- Since noticeable correlation exists between sedentary time and sleep time, Sleepr's new wellness tracker should heavily emphasize a sedentary (or "screen") timer.  The purpose of this timer would be to not only encourage the users to get up and stretch from time to time, but also to make them aware when they're approaching the maximum daily sedentary time before it starts impacting a healthy sleep cycle.  This threshold may vary from user to user, but our graphs seem to suggest that exceeding a maximum of 8 to 10 hours a day of "screen" time will adversely affect the respective user's sleep.  

- The majority of the proxied data shows that users spend most of their time in sedentary states, meaning its not necessarily fitness fanatics who are buying wellness trackers.  Many of these users may already be using the product to quantify how their habits are effecting their general wellness, but not all of them are wearing their trackers to bed (perhaps because its not comfortable, or they just need to charge the tracker).  Sleepr could emphasize the integration of wellness tracking sensors between their proposed bracelet trackers and their smart-beds, offering their users 24 hour sensory tracking for more complete analytics.

- Marketing opportunities may exist for other products.  If the majority of sedentary time is spent during the workday (presumably in front of a computer), Sleepr could market "standing desks" to users of its wellness tracker.


### Opportunities for future analysis:

- As mentioned earlier, our dataset was fairly limited, not only by the number of unique datapoints but also the table features.  We don't have any data regarding how the users are spending their time (while sedentary), their ages, diet, or any medical information that might affect the sleep they enjoy at night.  Integration of data like this to future analysis might help the client create more accurate and personalized wellness recommendations to the users.
- More than anything else, a larger amount of user data is needed.  With more data, it would be possible to create a machine learning model to predict the amount of sleep a user can expect based on their recorded habits.