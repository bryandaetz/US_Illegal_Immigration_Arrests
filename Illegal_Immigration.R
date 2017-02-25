#importing necessary libraries
library(tidyr)    #tidyr and stringr used for cleaning data
library(stringr)
library(plyr)     #plyr and dplyr used for aggregating data
library(dplyr)
library(ggplot2)  #ggplot2 and plotly used for data visualition
library(plotly)
library(ggmap)

#Importing Illegal Immigration data set from Kaggle
arrests <- read.csv("C://Users/bdaet/Downloads/arrests.csv")

#attempting to clean the untidy dataframe
arrests <- gather(arrests, Description, Number_Arrested, -Border, -Sector, -State.Territory)
arrests <- separate(arrests, Description, c("Year", "Demographic"))

#removing the X's from the Year column
arrests$Year <- gsub(pattern = "X", replacement = "", x = arrests$Year)

#the Year column is currently a character vector and we need it to be a numerical vector to be able to create
#meaningful graphs
arrests$Year <- as.integer(arrests$Year)

#changing "All" in the Demographic column to "All Immigrants" to make it more clear
arrests$Demographic <- str_replace(arrests$Demographic, "All", "All Immigrants")

#creating a csv file of the cleaned dataset
write.csv(arrests, file = "immigration_arrests.csv")

#creating a new dataframe with yearly arrest totals
#it appears the original dataframe already included totals as observations where Border == United States
totals <- arrests %>%
              group_by(Year, Demographic) %>%
              filter(Border == "United States") %>%
              arrange(Demographic)

#creating an area plot comparing yearly arrest totals of all immigrants and of only mexican immigrants 
tot <- ggplot(totals, aes(x = Year, y = Number_Arrested, fill = Demographic)) +
          geom_area(alpha = 0.65, position = "dodge") +
          scale_fill_manual(values = c("skyblue1", "skyblue4")) +
          xlab("Year") +
          ylab("Total Arrests") +
          ggtitle("Total Illegal Immigration Arrests") +
          theme_minimal()
ggplotly(tot)


#creating a new dataframe with yearly arrest totals by border
#again the original dataframe already included this totals as observations where Sector == All
by_border <- arrests %>%
                  group_by(Year, Demographic) %>%
                  filter(Sector == "All") %>%
                  arrange(Demographic)

#creating area plots for each border comparing the yearly arrest totals of all immigrants and of only mexicans
borders <- ggplot(by_border, aes(x = Year, y = Number_Arrested, fill = Demographic)) +
              geom_area(alpha = 0.65, position = "dodge") +
              scale_fill_manual(values = c("skyblue1", "skyblue4")) +
              facet_wrap(~ Border) +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests at Each Border") +
              theme_bw()
ggplotly(borders)

#since the arrest totals are so much higher for the southwest than for the other two borders it may make more sense
#   create individual graphs for each border instead of facet wrapping

coast <- ggplot(filter(by_border, Border == "Coast"), 
                aes(x = Year, y = Number_Arrested, fill = Demographic)) +
              geom_area(alpha = 0.65, position = "dodge") +
              scale_fill_manual(values = c("skyblue1", "skyblue4")) +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests Along the Coast") +
              theme_minimal()
ggplotly(coast)

north <- ggplot(filter(by_border, Border == "North"), 
                aes(x = Year, y = Number_Arrested, fill = Demographic)) +
              geom_area(alpha = 0.65, position = "dodge") +
              scale_fill_manual(values = c("skyblue1", "skyblue4")) +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests at Northern Border") +
              theme_minimal()
ggplotly(north)

southwest <- ggplot(filter(by_border, Border == "Southwest"), 
                    aes(x = Year, y = Number_Arrested, fill = Demographic)) +
              geom_area(alpha = 0.65, position = "dodge") +
              scale_fill_manual(values = c("skyblue1", "skyblue4")) +
              xlab("Year") +
              ylab("Total Arrests") +
              ggtitle("Illegal Immigration Arrests at Southwest Border") +
              theme_minimal()
ggplotly(southwest)

#while this approach was much more tedious, it made the graphs significantly easier to read


#creating barplots comparing the arrest totals in the Sectors with the 8 highest arrest totals for 2000, 2005,
# 2010 and 2016
mostarrests <- filter(arrests, Sector %in% c("Del Rio",
                                             "El Centro",
                                             "El Paso",
                                             "Laredo",
                                             "Rio Grande Valley",
                                             "San Diego",
                                             "Tucson",
                                             "Yuma"),
                               Year %in% c(2000, 2005, 2010, 2016))
mostarrests$Demographic <- ordered(mostarrests$Demographic, levels = c("Mexicans", "All Immigrants"))
#setting the level order for the Type attribute so the smaller values on the bar plot aren't hidden

sectors <- ggplot(mostarrests, aes(x = Sector, y = Number_Arrested, fill = Demographic)) +
              geom_bar(stat = "identity", position = "identity", alpha = 0.65) +
              scale_fill_manual(values = c("skyblue4", "skyblue1")) +
              xlab("Sector") +
              ylab("Total Arrests") +
              facet_wrap(~ Year) +
              theme_bw()+
              theme(axis.text.x = element_text(size = 6))
ggplotly(sectors)

#This comparision is nice but it is based on the Sectors with the 8 highest arrest total from 2000.  It is 
# possible that in later years the Sectors with the highest arrest totals changed.  Also we can only see
# the arrest totals from 4 of the 17 years that we have data on.  Unfortunately, adding more years to this plot
# would make it too hard to read, and it would be tedious to rewrite the code for a bar plot 17 times to look
# at the information for each year individually. For this reason I chose to write a function that can find the
# Sectors with the 8 highest arrest totals for a given year and create a bar plot comparing the arrest totals 
# for all illegal immigrants and mexican immigrants for that year.

yearPlot <- function(yr, title = paste("Sectors with the Highest Arrest Totals in", as.character(yr))) {
    temp <- filter(arrests, Sector != "", Sector != "All", Year == yr) #filtering out rows that don't apply to
                                                                    ## to a specific Sector
                                                                      #filtering by the provided Year value
    
    top8 <- temp %>%
              filter(Demographic == "All Immigrants") %>% 
      #finding the Sectors with the 8 highest arrest totals for that year
              arrange(desc(Number_Arrested))            
    top8 <- top8[1:8,]
    
    temp <- filter(temp, Sector %in% top8$Sector)  #filtering by the Sectors w/ the 8 highest arrest totals
    temp$Demographic <- ordered(temp$Demographic, levels = c("Mexicans", "All Immigrants"))
                                                              #setting the level order for the Demographic
                                                              # attribute so the smaller values on the bar plot
                                                              # aren't hidden
    
    
    #creating a bar plot comparing the arrest totals for all illegal immigrants and for only mexican immigrants
    plot <- ggplot(temp, aes(x = Sector, y = Number_Arrested, fill = Demographic)) +
                geom_bar(stat = "identity", position = "identity", alpha = .65) +
                scale_fill_manual(values = c("skyblue4", "skyblue1")) +
                xlab("Sector") +
                ylab("Total Arrests") +
                ggtitle(title) +
                theme_minimal() +
                theme(axis.text.x = element_text(size = 8))
    ggplotly(plot)    #making the plot interactive
}    
yearPlot(2000)
yearPlot(2016)

#creating a vector with all the different sectors
Sector <- levels(arrests$Sector)
#taking out the sectors "All" and "" which are used for totals and aren't actual individual sectors
Sector <- Sector[3:length(Sector)]

#using the geocode command to get the latitude and longitude for each sector
locations <- data.frame(Sector, geocode(Sector, output = "latlon"))

#subset of arrests dataframe with only the rows for individual sectors, no totals
arrests2 <- filter(arrests, Sector != "", Sector != "All")

#merging the arrests2 and locations dataframes to get the latitude and longitude information for each Sector
arrests_loc <- join(x = arrests2, y = locations,
                    by = "Sector", type = "left")


# getting a map of the United States to show the areas with the most arrests
# this was the example US map from the plotly documentation page
g <- list(
  scope = "usa",
  projection = list(type = "albers usa"),
  showland = TRUE,
  landcolor = toRGB("gray95"),
  subunitcolor = toRGB("gray85"),
  countrycolor = toRGB("gray85"),
  countrywidth = 0.5,
  subunitwidth = 0.5
)

#creating a function to create a map of the areas with the most arrests for a given year
mapPlot <- function(yr, title = paste("Illegal Immigration Arrests in", as.character(yr))) {
        tmp <- filter(arrests_loc, Year == yr)
        p <- plot_geo(tmp, lat = ~lat, lon = ~lon, 
                      color = ~Demographic, 
                      colors = c("skyblue1", "skyblue4"), 
                      size = ~Number_Arrested,
                      sizes = c(10, 300),
                      alpha = 0.65,
                      text = ~paste('Demographic: ', Demographic, 
                        '</br> Sector: ', Sector,
                        '</br> Arrests: ', Number_Arrested)) %>%
          add_markers() %>%
          layout(title = title, geo = g)
        print(p)
}

mapPlot(2000)
mapPlot(2016)



