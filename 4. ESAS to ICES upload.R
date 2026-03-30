# This script combines the four ESAS tables into a single matrix, which can be uploaded to ICES 
# We run this code separately for both research vessels, resulting in two files for upload in the ICES portal

# First research vessel: Simon Stevin ####

#Read data
setwd("G:/Mijn Drive/Mijn Documenten/SAS DB 2024/Update SAS juni 2025")
CAMPAIGNS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/CAMPAIGNS_BE_ICES_update_jul_2025_example.csv", fileEncoding = "UTF-8")
SAMPLES <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/SAMPLES_BE_ICES_update_jul_2025_example.csv", fileEncoding = "UTF-8")
POSITIONS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/POSITIONS_BE_ICES_update_jul_2025_example.csv", fileEncoding = "UTF-8")
OBSERVATIONS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/OBSERVATIONS_BE_ICES_update_jul_2025_example.csv", fileEncoding = "UTF-8")

#Add RecordTypes
CAMPAIGNS <- CAMPAIGNS %>%
  mutate(RecordType = "EC") %>%
  relocate(RecordType)

SAMPLES <- SAMPLES %>%
  mutate(RecordType = "ES") %>%
  relocate(RecordType)

POSITIONS <- POSITIONS %>%
  mutate(RecordType = "EP") %>%
  relocate(RecordType)

OBSERVATIONS <- OBSERVATIONS %>%
  mutate(RecordType = "EO") %>%
  relocate(RecordType)

#As matrices
FILE_INFORMATION <- matrix(nrow=1,ncol=18)
FILE_INFORMATION[1,1:3] <- c("FI","202","BE")

CAMPAIGNS_matrix <- matrix(nrow=nrow(CAMPAIGNS),ncol=18)
CAMPAIGNS_matrix[,1:6] <- as.matrix(CAMPAIGNS)

SAMPLES_matrix <- matrix(nrow=nrow(SAMPLES),ncol=18)
SAMPLES_matrix[,1:16] <- as.matrix(SAMPLES)

POSITIONS_matrix <- matrix(nrow=nrow(POSITIONS),ncol=18)
POSITIONS_matrix[,1:16] <- as.matrix(POSITIONS)

OBSERVATIONS_matrix <- matrix(nrow=nrow(OBSERVATIONS),ncol=18)
OBSERVATIONS_matrix[,1:18] <- as.matrix(OBSERVATIONS)

#Bind matrices
ESAS_2_ICES_DB <- rbind(FILE_INFORMATION,
                        CAMPAIGNS_matrix,
                        SAMPLES_matrix,
                        POSITIONS_matrix,
                        OBSERVATIONS_matrix)

ESAS_2_ICES_DB[is.na(ESAS_2_ICES_DB)] <- ""
ESAS_2_ICES_DB <- as.data.frame(ESAS_2_ICES_DB)
head(ESAS_2_ICES_DB)

#Write data
write.table(ESAS_2_ICES_DB, "ESAS_INBO_2025_07_09_A_example.csv", sep="\t", row.names=F, col.names=F, quote=F, 
            fileEncoding = "UTF-8")


# Second research vessel: Belgica ####

#Read data
setwd("G:/Mijn Drive/Mijn Documenten/SAS DB 2024/Update SAS juni 2025")
CAMPAIGNS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/CAMPAIGNS_BE_ICES_update_jul_2025_B_example.csv", fileEncoding = "UTF-8")
SAMPLES <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/SAMPLES_BE_ICES_update_jul_2025_B_example.csv", fileEncoding = "UTF-8")
POSITIONS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/POSITIONS_BE_ICES_update_jul_2025_B_example.csv", fileEncoding = "UTF-8")
OBSERVATIONS <- read.csv("https://raw.githubusercontent.com/RobinDaelemans/ESAS-code-INBO/refs/heads/main/OBSERVATIONS_BE_ICES_update_jul_2025_B_example.csv", fileEncoding = "UTF-8")

#Add RecordTypes
CAMPAIGNS <- CAMPAIGNS %>%
  mutate(RecordType = "EC") %>%
  relocate(RecordType)

SAMPLES <- SAMPLES %>%
  mutate(RecordType = "ES") %>%
  relocate(RecordType)

POSITIONS <- POSITIONS %>%
  mutate(RecordType = "EP") %>%
  relocate(RecordType)

OBSERVATIONS <- OBSERVATIONS %>%
  mutate(RecordType = "EO") %>%
  relocate(RecordType)

#As matrices
FILE_INFORMATION <- matrix(nrow=1,ncol=18)
FILE_INFORMATION[1,1:3] <- c("FI","202","BE")

CAMPAIGNS_matrix <- matrix(nrow=nrow(CAMPAIGNS),ncol=18)
CAMPAIGNS_matrix[,1:6] <- as.matrix(CAMPAIGNS)

SAMPLES_matrix <- matrix(nrow=nrow(SAMPLES),ncol=18)
SAMPLES_matrix[,1:16] <- as.matrix(SAMPLES)

POSITIONS_matrix <- matrix(nrow=nrow(POSITIONS),ncol=18)
POSITIONS_matrix[,1:16] <- as.matrix(POSITIONS)

OBSERVATIONS_matrix <- matrix(nrow=nrow(OBSERVATIONS),ncol=18)
OBSERVATIONS_matrix[,1:18] <- as.matrix(OBSERVATIONS)

#Bind matrices
ESAS_2_ICES_DB <- rbind(FILE_INFORMATION,
                        CAMPAIGNS_matrix,
                        SAMPLES_matrix,
                        POSITIONS_matrix,
                        OBSERVATIONS_matrix)

ESAS_2_ICES_DB[is.na(ESAS_2_ICES_DB)] <- ""
ESAS_2_ICES_DB <- as.data.frame(ESAS_2_ICES_DB)
head(ESAS_2_ICES_DB)

#Write data
write.table(ESAS_2_ICES_DB, "ESAS_INBO_2025_07_09_B_example.csv", sep="\t", row.names=F, col.names=F, quote=F, 
            fileEncoding = "UTF-8")
