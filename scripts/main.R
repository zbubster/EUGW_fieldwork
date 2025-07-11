# skript

source("scripts/knihovnik.R", echo = F)
knihovnik(c("sf", "dplyr", "stringr"))

# load and prepare VMB
vmb <- st_read("data/VMB_cliped.gpkg")

source("scripts/BIO_HAB_codes.R")
vmb <- vmb %>%
  BIO_HAB_codes() %>% #replace xxx_SEZ with xxx_CODES
  select(SEGMENT_ID, FSB, BIOTOP_CODES, HABIT_CODES, DATUM) %>% #select relevant cols
  filter(FSB != "-" & FSB != "moz.") # drop 'nonmapped' features

# load crosswalk
cross <- read.csv("EUNIS_level2_crosswalk.csv", header = T, sep = "\t")

# delete spaces
cross$CZECH_classes <- gsub("; ", ";", cross$CZECH_classes)

# EUNIS_L2 codes against CZECH_codes (one to many)
GT <- data.frame(EUNIS_L2 = factor(), CZECH_codes = factor())
for(i in 1:length(cross$Code)){
  cat("Processing:", cross$Code[i], "\n")
  EUNIS <- cross$Code[i]
  codes <- unique(strsplit(cross$CZECH_classes[i], ";")[[1]])
  nr <- data.frame(EUNIS_L2 = EUNIS, CZECH_codes = codes)
  GT <- rbind(GT, nr)
}

# crate short version of BIOTOP_CODES
# otherwise left_join will not work, due to lower hierarchical level within 'vmb'
# in GT: T3.4 but in VMB: T3.4D
vmb <- vmb %>%
  mutate(
    BIOTOP_SHORT = if_else( # pokud se jedna o LP, zapis LP a pokracuj
        BIOTOP_CODES == "LP",
        BIOTOP_CODES,
        if_else( # pokud je na konci retezce pismeno, urizni toto pismeno a zapis zkracenou verzi, jinak zapis original
          str_detect(BIOTOP_CODES, "[A-Z]$"),
          str_sub(BIOTOP_CODES, 1, -2),
          BIOTOP_CODES
        )
      )
    )

# join
vmb <- vmb %>%
  left_join(GT, by = c("BIOTOP_SHORT" = "CZECH_codes"))

# write result
st_write(vmb, "data/VMB_with_EUNIS_L2.gpkg")
