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
#it appears the original dataframe already included totals as observations where Border == United States
totals <- arrests %>%
              group_by(Year, Type) %>%
              filter(Border == "United States") %>%
              arrange(Type)

#creating an area plot comparing yearly arrest totals of all immigrants and of only mexican immigrants 
tot <- ggplot(totals, aes(x = Year, y = Number_Arrested, fill = Type)) +
          geom_area(alpha = 0.65, position = "dodge") +
          xlab("Year") +
          ylab("Total Arrests") +
          ggtitle("Illegal Immigration Arrests") +
          theme_minimal()
ggplotly(tot)


#creating a new dataframe with yearly arrest totals by border
#again the original dataframe already included this totals as observations where Sector == All
by_border <- arrests %>%
                  group_by(Year, Type) %>%
                  filter(Sector == "All") %>%
                  arrange(Type)

#creating area plots for each border comparing the yearly arrest totals of all immigrants and of only mexicans
borders <- ggplot(by_border, aes(x = Year, y = Number_Arrested, fill = Type)) +
              geom_area(alpha = 0.65, position = "dodge") +
              facet_wrap(~ Border) +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests at Each Border") +
              theme_bw()
ggplotly(borders)

#since the arrest totals are so much higher for the southwest than for the other two borders it may make more sense
#   create individual graphs for each border instead of facet wrapping

coast <- ggplot(filter(by_border, Border == "Coast"), aes(x = Year, y = Number_Arrested, fill = Type)) +
              geom_area(alpha = 0.65, position = "dodge") +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests Along the Coast") +
              theme_minimal()
ggplotly(coast)

north <- ggplot(filter(by_border, Border == "North"), aes(x = Year, y = Number_Arrested, fill = Type)) +
              geom_area(alpha = 0.65, position = "dodge") +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests at Northern Border") +
              theme_minimal()
ggplotly(north)

southwest <- ggplot(filter(by_border, Border == "Southwest"), aes(x = Year, y = Number_Arrested, fill = Type)) +
              geom_area(alpha = 0.65, position = "dodge") +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests at Southwest Border") +
              theme_minimal()
ggplotly(southwest)

#while this approach was much more tedious, it made the graphs significantly easier to read
            






