#Importing Illegal Immigration data set from Kaggle
arrests <- read.csv("C://Users/bdaet/Downloads/arrests.csv")

#importing necessary libraries
library(ggplot2)
library(tidyr)
library(plotly)
library(dplyr)

#attempting to clean the untidy dataframe
arrests <- gather(arrests, Description, Number_Arrested, -Border, -Sector, -State.Territory)
arrests <- separate(arrests, Description, c("Year", "Type"))

#removing the X's from the Year column
arrests$Year <- gsub(pattern = "X", replacement = "", x = arrests$Year)

#the Year column is currently a character vector and we need it to be a numerical vector to be able to create
#meaningful graphs
arrests$Year <- as.integer(arrests$Year)

#creating a csv file of the cleaned dataset
write.csv(arrests, file = "immigration_arrests.csv")

#creating a new dataframe with yearly arrest totals
totals <- arrests %>%
              group_by(Year, Type) %>%
              summarise(Total_Arrests = sum(Number_Arrested, na.rm = TRUE)) %>%
              arrange(Type)

#creating an area plot comparing yearly arrest totals of all immigrants and of only mexican immigrants 
tot <- ggplot(totals, aes(x = Year, y = Total_Arrests, fill = Type)) +
          geom_area(alpha = 0.65, position = "dodge") +
          xlab("Year") +
          ylab("Total Arrests") +
          ggtitle("Illegal Immigration Arrests") +
          theme_minimal()
ggplotly(tot)







