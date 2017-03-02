# US Illegal Immigration Arrests

## Analysis of US Illegal Immigration Arrests from 2000-2016 Using R

# Table of Contents
* Project Goal
* Notes About the Dataset
* Overview of Arrest Trends
* A Look at Arrests at Each Border
* Breakdown of Arrests by Sector

## Project Goal
Illegal immigration has always been a controversial issue.  This is especially true now with our country's current politcal situation.  Like everyone else, I have my own opinions on the topic, but I will do my best to remain unbiased in my analysis and report only facts rather than opinions.  My goal is to explore trends in US illegal immigration arrests from 2000-2016 as objectively as possible.

## Notes About the Dataset
The dataset I used for this project can be found on the Kaggle website.

Here is a link to the original dataset:
https://www.kaggle.com/cbp/illegal-immigrants

The original dataset was extremely messy so it required some cleaning before any analysis could be done.  I have uploaded the "clean" dataset as a csv file as well.  It contains information on two demographics: Mexican Illegal Immigrants and All Illegal Immigrants.

It is important to note that the numbers listed are only the illegal immigrants that were ARRESTED.  This means that there were almost certainly more illegal immigrants each year that managed to enter the country unnoticed.  As such I cannot claim that my analysis is an accurate representation of trends in illegal immigration overall; it only extends to illegal immigrants that were arrested.

## Overview of Arrest Trends
Looking at the overall arrest totals for each year, it is immediately apparent that the numbers have been decreasing overall for both demographics.  With the exception of a spike in arrests in the years 2004 and 2005, the numbers have consistently decreased each year.

Additionally, the percentage of the arrests accounted for by Mexican Illegal Immigrants began decreasing significantly starting in 2010 and dropped down to only 46.41% in 2016.

![alt-title](Illegal Immigration Images/Illegal Immigration Arrest Totals by Year.png)

|   Year | Percentage | Mexicans Arrested | Total Arrests |
|--------|------------|-------------------|---------------|
|  2000   |   97.64    |      1636883   |    1676438     |
| 2001    |  96.67     |     1224047     |  1266214       |
| 2002    | 96.09      |      917993     |   955310       |
|  2003   |   94.68    |       882012    |   931557       |
|  2004   |   93.50     |      1085006    |   1160395      |
|  2005   |   86.11    |      1023905     |  1189075      |
|  2006   |   90.08    |        981066    |   1089092     |
|  2007   |   92.24     |       808688    |    876704     |
|  2008   |   91.43     |       661766    |    723825     |
| 2009    |  90.53      |      503386     |   556041      |
| 2010    |  87.26      |     404365      |  463382       |
| 2011    |  84.10      |      286154     |   340252      |
| 2012    |  72.86      |      265755     |   364768      |
| 2013    |  63.63      |      267734     |   420789      |
| 2014    |  47.09      |      229178     |   486651      |
| 2015    |  55.80      |      188122     |   337117      |
| 2016    |  46.41      |      192969     |   415816      |


