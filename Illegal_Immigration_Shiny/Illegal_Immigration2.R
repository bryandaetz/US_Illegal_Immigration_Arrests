#importing necessary libraries
library(tidyr)    #tidyr and stringr used for cleaning data
library(stringr)
library(plyr)     #plyr and dplyr used for aggregating data
library(dplyr)
library(ggplot2)  #ggplot2 and plotly used for data visualition
library(plotly)
library(ggmap)   #ggmap used for geocode function to get latitude and longitude info for cities

#Importing Illegal Immigration data set from Kaggle
arrests <- read.csv("C://Users/bdaet/Desktop/myProjects/arrests.csv")
arrests_loc <- read.csv("C://Users/bdaet/Desktop/myProjects/arrestLocations.csv")

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


#Since the arrest totals are so much higher for the southwest than for the other two borders it may make more 
#sense to create individual graphs for each border instead of facet wrapping.
#To avoid rewriting the code for the graph for each border I chose to write a function that will create a graph
#for a given border.
border <- function(x, title) {
  t <- ggplot(filter(by_border, Border == x), 
              aes(x = Year, y = Number_Arrested, fill = Demographic)) +
    geom_area(alpha = 0.65, position = "dodge") +
    scale_fill_manual(values = c("skyblue1", "skyblue4")) +
    xlab("Year") +
    ylab("Total Arrests") +
    ggtitle(title) +
    theme_minimal()
  ggplotly(t)
}

border("Coast", "Illegal Immigration Arrests Along the Coast")
border("North", "Illegal Immigration Arrests at Northern Border")
border("Southwest", "Illegal Immigration Arrests at Southwest Border")


#This comparision is nice but it is based on the Sectors with the 8 highest arrest total from 2000.  It is 
# possible that in later years the Sectors with the highest arrest totals changed.  Also we can only see
# the arrest totals from 4 of the 17 years that we have data on.  Unfortunately, adding more years to this plot
# would make it too hard to read, and it would be tedious to rewrite the code for a bar plot 17 times to look
# at the information for each year individually. For this reason I chose to write a function that can find the
# Sectors with the 8 highest arrest totals for a given year and create a bar plot comparing the arrest totals 
# for all illegal immigrants and mexican immigrants for that year.

yearPlot <- function(yr) {
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
    coord_flip() +
    scale_fill_manual(values = c("skyblue4", "skyblue1")) +
    ylab("Total Arrests") +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 7, angle = 30),
          axis.title.y = element_blank(),
          axis.text.x = element_blank())
  ggplotly(plot)    #making the plot interactive
}    
yearPlot(2000)
yearPlot(2016)


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
mapPlot <- function(yr, title = paste("Sectors with the Most Arrests in", as.character(yr))) {
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

#creating separate dataframes with just "Mexicans" arrests and just "All Immigrants" arrests to find the percentage
# of arrests accounted for by Mexican immigrants each year
mexican_arrests <-  filter(arrests, Border == "United States", Demographic == "Mexicans")
all_arrests <- filter(arrests, Border == "United States", Demographic == "All Immigrants")

#creating a new dataframe with these percentages (rounded to 2 decimal places) as well as the number of Mexican
# immigrants arrested and the total number of arrests for each year
percentages <- data.frame(all_arrests$Year, 
                          mexican_arrests$Number_Arrested,
                          all_arrests$Number_Arrested,
                          round(mexican_arrests$Number_Arrested / all_arrests$Number_Arrested * 100, digits = 2))
names(percentages) <- c("Year","Mexicans_Arrested", "Total_Arrests", "Percentage")

percentages






