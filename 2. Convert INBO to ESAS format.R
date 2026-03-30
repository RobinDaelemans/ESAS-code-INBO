# This script converts the internal INBO database (consisting of the tables TRIPALL, BASEALL and OBSALL) into the ESAS data format
# consisting of the tables CAMPAIGNS, SAMPLES, POSITIONS and OBSERVATIONS. 
# As we at INBO use some slightly different coding (for instance for associations and behaviour), this script also converts these codes to the correct ESAS codes
# In Belgium we only have two research vessels and we run this code separately for each vessel because some variables in the dataset 'SAMPLES' are different
# for different vessels (eg the hight of the platform from which the observations are made). In a next step, we will first add data from the first vessel to the long-term database,
# and subsequently add the data from the second vessel to the database. Also the upload of our data to the ICES portal happens in two steps, once for each vessel. 
# If there is uncertainty about variables: check the ESAS data model!

# Load packages used in this script
library(tidyverse)
library(lubridate)
library(readxl)

# Load the internal INBO database (we use a subset in this example)
TRP <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/TRIPALL_MERGE_1992_2024_b_example.csv", fileEncoding = "UTF-8")
POS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/BASEALL_MERGE_1992_2024_b_example.csv", fileEncoding = "UTF-8")
OBS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/BIRDALL_MERGE_1992_2024_b_example.csv", fileEncoding = "UTF-8")

# Select vessel
# Select surveys: in this example we only want to upload the surveys/trips from 2024 onwards to the ESAS database
TRP <- TRP[ymd(TRP$Date) > "2024-01-01" & TRP$Ship == "SBE2",] # Use 'SBE2' for vessel 'Belgica', use "SST" for vessel 'Simon Stevin'
POS <- POS[POS$Tripkey %in% TRP$Tripkey,]
OBS <- OBS[OBS$Poskey %in% POS$Poskey,]


# Convert variable names and select variables
# Only variables relevant for the Belgian surveys are included,
# a more extensive list of variables is available at the ESAS data model


#CAMPAIGNS
#Conversion
CAMPAIGNS <- TRP
CAMPAIGNS <- CAMPAIGNS %>% mutate("ICES_CampaignID" = Tripkey)
CAMPAIGNS <- CAMPAIGNS %>% mutate("ICES_DataAccess" = "Public")
CAMPAIGNS <- CAMPAIGNS %>% mutate("ICES_StartDate" = Date)
CAMPAIGNS <- CAMPAIGNS %>% mutate("ICES_EndDate" = Date)
CAMPAIGNS <- CAMPAIGNS %>% mutate("ICES_Notes" = NA)
#select column and trim column names
CAMPAIGNS <- CAMPAIGNS %>% select(starts_with("ICES_"))
colnames(CAMPAIGNS) <- str_remove(colnames(CAMPAIGNS), "ICES_")


#SAMPLES
#Conversie:
SAMPLES <- TRP
SAMPLES <- SAMPLES %>% mutate("ICES_CampaignID" = Tripkey)
SAMPLES <- SAMPLES %>% mutate("ICES_SampleID" = Tripkey)
SAMPLES <- SAMPLES %>% mutate("ICES_Date" = Date)
SAMPLES <- SAMPLES %>% mutate("ICES_PlatformCode" = "11BU") # for Belgica 11BU, for SST 11SS
SAMPLES <- SAMPLES %>% mutate("ICES_PlatformClass" = 30)    # 30 = ship
SAMPLES <- SAMPLES %>% mutate("ICES_PlatformSide" = NA)
SAMPLES <- SAMPLES %>% mutate("ICES_PlatformHeight" = NA)
SAMPLES <- SAMPLES %>% mutate("ICES_TransectWidth" = 300)
SAMPLES <- SAMPLES %>% mutate("ICES_SamplingMethod" = 1)
SAMPLES <- SAMPLES %>% mutate("ICES_PrimarySampling" = TRUE)
SAMPLES <- SAMPLES %>% mutate("ICES_TargetTaxa" = 1)
SAMPLES <- SAMPLES %>% mutate("ICES_DistanceBins" = "0|50|100|200|300")
SAMPLES <- SAMPLES %>% mutate("ICES_UseOfBinoculars" = 3)
SAMPLES <- SAMPLES %>% mutate("ICES_NumberOfObservers" = 1) # (only Nicolas was present)
SAMPLES <- SAMPLES %>% mutate("ICES_Notes" = NA)
#select column and trim column names
SAMPLES <- SAMPLES %>% select(starts_with("ICES_"))
colnames(SAMPLES) <- str_remove(colnames(SAMPLES), "ICES_")


#POSITIONS
#Round coordinates
POS$MidLatitude_rev <- sprintf("%.4f", round(POS$MidLatitude, 4))
POS$MidLongitude_rev <- sprintf("%.4f", round(POS$MidLongitude, 4))
POS$Distance_rev <- sprintf("%.4f", round(POS$Distance, 4))
POS$Area_rev <- sprintf("%.4f", round(POS$Area, 4))

#Conversie:
POSITIONS <- POS
POSITIONS <- POSITIONS %>% mutate("ICES_SampleID" = Tripkey)
POSITIONS <- POSITIONS %>% mutate("ICES_PositionID" = Poskey)
POSITIONS <- POSITIONS %>% mutate("ICES_Time" = Time)
POSITIONS <- POSITIONS %>% mutate("ICES_Latitude" = MidLatitude_rev)
POSITIONS <- POSITIONS %>% mutate("ICES_Longitude" = MidLongitude_rev)
POSITIONS <- POSITIONS %>% mutate("ICES_Distance" = Distance_rev)
POSITIONS <- POSITIONS %>% mutate("ICES_Area" = Area_rev)
POSITIONS <- POSITIONS %>% mutate("ICES_WindForce" = Beaufort)
POSITIONS <- POSITIONS %>% mutate("ICES_Visibility" = Visibility)
POSITIONS <- POSITIONS %>% mutate("ICES_Glare" = Glare)
POSITIONS <- POSITIONS %>% mutate("ICES_SunAngle" = NA)
POSITIONS <- POSITIONS %>% mutate("ICES_CloudCover" = NA)
POSITIONS <- POSITIONS %>% mutate("ICES_Precipitation" = Precipitation)
POSITIONS <- POSITIONS %>% mutate("ICES_IceCover" = 0)
POSITIONS <- POSITIONS %>% mutate("ICES_ObservationConditions" = NA)
#select column and trim column names
POSITIONS <- POSITIONS %>% select(starts_with("ICES_"))
colnames(POSITIONS) <- str_remove(colnames(POSITIONS), "ICES_")


#OBSERVATIONS
table(OBS$Distance, OBS$Transect)
OBS <- OBS %>% mutate(
  Distance = ifelse(Distance %in% c("U"), "W", Distance), #change distance 'U' into "W" following the ESAS data model
  Distance = ifelse(Distance %in% c("1","2","3"), "F", Distance),
  Distance = ifelse(Distance%in%c("E") & Transect == 1, "W", Distance))
table(OBS$Distance)
levels(as.factor(OBS$Distance))

#Map columns with new vocabulary (replace inbo codes for associtions and behaviour by the correct ESAS codes)
setwd("G:/Mijn Drive/Mijn Documenten/SAS DB 2024/Update SAS juni 2025")
ASS <-  as.data.frame(read_excel("BE_Association.xlsx")) # internal INBO codes for associations
BEH <-  as.data.frame(read_excel("BE_Behaviour.xlsx")) # internal INBO codes for behaviour

#Association
OBS$Association_recoded <- plyr::mapvalues(OBS$Association, 
                                           from = ASS$Association_INBO, to = ASS$Association_ESAS)
table(OBS$Association)
table(OBS$Association_recoded)
sum(table(OBS$Association))==sum(table(OBS$Association_recoded))

#Behaviour
OBS$Behaviour_recoded <- plyr::mapvalues(OBS$Behaviour, 
                                         from = BEH$Behaviour_INBO, to = BEH$Behaviour_ESAS)
table(OBS$Behaviour)
table(OBS$Behaviour_recoded)
sum(table(OBS$Behaviour))==sum(table(OBS$Behaviour_recoded))

#Transect
OBS$Transect <- as.logical(OBS$Transect)
table(OBS$Transect)

#Resolve problems with species codes:
# (some species codes that we use at INBO do not align with the species codes in the ESAS data model)
table(OBS$Species)
str(OBS$Species)
OBS <- OBS %>%
  filter(Species != "9999") %>% # we use code 9999 to record other vessels but this is not included in the ESAS database
  mutate(Species = case_when(
    Species == "24310" ~ "64310",
    Species == "24320" ~ "64320",
    Species == "24330" ~ "64330",
    Species == "5928"  ~ "5926",
    Species == "6005"  ~ "6009",
    TRUE ~ Species
  ))
table(OBS$Species)

#Conversie:
OBSERVATIONS  <- OBS
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_PositionID" = Poskey)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_ObservationID" = Obskey)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_GroupID" = Group)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Transect" = Transect)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_SpeciesCodeType" = "ESAS")
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_SpeciesCode" = Species)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Count" = Count)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_ObservationDistance" = Distance)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_LifeStage" = Age)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Moult" = NA)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Plumage" = Plumage)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Sex" = Sex)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_TravelDirection" = Direction)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Prey" = Prey)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Association" = Association_recoded)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Behaviour" = Behaviour_recoded)
OBSERVATIONS <- OBSERVATIONS %>% mutate("ICES_Notes" = Notes)
#select column and trim column names
OBSERVATIONS <- OBSERVATIONS %>% select(starts_with("ICES_"))
colnames(OBSERVATIONS) <- str_remove(colnames(OBSERVATIONS), "ICES_")


#SAVE FILES FOR VESSEL SIMON STEVIN
setwd("G:/Mijn Drive/Mijn Documenten/SAS DB 2024/Update SAS juni 2025")
write.csv(CAMPAIGNS,"CAMPAIGNS_BE_ICES_update_jul_2025.csv", row.names = F, fileEncoding = "UTF-8")
write.csv(SAMPLES,"SAMPLES_BE_ICES_update_jul_2025.csv", row.names = F, fileEncoding = "UTF-8")
write.csv(POSITIONS,"POSITIONS_BE_ICES_update_jul_2025.csv", row.names = F, fileEncoding = "UTF-8")
write.csv(OBSERVATIONS,"OBSERVATIONS_BE_ICES_update_jul_2025.csv", row.names = F, fileEncoding = "UTF-8")

#SAVE FILES FOR VESSEL BELGICA
setwd("G:/Mijn Drive/Mijn Documenten/SAS DB 2024/Update SAS juni 2025")
write.csv(CAMPAIGNS,"CAMPAIGNS_BE_ICES_update_jul_2025_B.csv", row.names = F, fileEncoding = "UTF-8")
write.csv(SAMPLES,"SAMPLES_BE_ICES_update_jul_2025_B.csv", row.names = F, fileEncoding = "UTF-8")
write.csv(POSITIONS,"POSITIONS_BE_ICES_update_jul_2025_B.csv", row.names = F, fileEncoding = "UTF-8")
write.csv(OBSERVATIONS,"OBSERVATIONS_BE_ICES_update_jul_2025_B.csv", row.names = F, fileEncoding = "UTF-8")
