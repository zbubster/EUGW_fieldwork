## BIOTOP_CODES & HABIT_CODES
# update "xxx (%)" format within BIOTOP_SEZ and HABIT_SEZ to BIOTOP_CODES or HABIT_CODES, where only clessification codes are kept

BIO_HAB_codes <- function(vector){
  # checks if new cols needed 
  new_cols_needed <- !c("BIOTOP_CODES", "HABIT_CODES") %in% names(vector)
  
  # create newcols
  if(any(new_cols_needed)){
    new_cols <- data.frame(
      BIOTOP_CODES = as.factor(gsub(" \\(\\d+\\)", "", vector$BIOTOP_SEZ)),
      HABIT_CODES = as.factor(gsub(" \\(\\d+\\)", "", vector$HABIT_SEZ))
    )
  }
  
  # select only wanted cols from VMB layer
  out <- cbind(vector, new_cols)
  
  return(out)
}