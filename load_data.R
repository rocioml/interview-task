
load_data <- function () {

dir <- "../data/returns/"
file_list <- list.files(dir)
data_returns <- NULL
for (f in file_list) {
  dat <- read.csv(paste(dir, f, sep=""), header=F, sep="\t", na.strings="",
                  col.names=c("customerId2", "productId", "divisionId", "sourceId", "itemQty", 
                              "signalDate", "receiptId", "returnId", "returnAction", "returnReason"),
                  colClasses=c("integer", "integer", "factor", "factor", "integer", 
                               "Date", "integer", "integer", "factor", "factor"))
  data_returns <- rbind(data_returns, dat)
}

dir <- "../data/customer/"
file_list <- list.files(dir)
data_customer <- NULL
for (f in file_list) {
  dat <- read.csv(paste(dir, f, sep=""), header=F, sep="\t", na.strings="",
                  col.names=c("customerId2", "churnlabel", "gender", "shippingCountry", "dateCreated", 
                              "yearOfBirth", "premier"),
                  colClasses=c("integer", "integer", "factor", "factor", "Date", 
                               "integer", "factor"))
  data_customer <- rbind(data_customer, dat)
}

dir <- "../data/receipts/"
file_list <- list.files(dir)
data_receipts <- NULL
for (f in file_list) {
  dat <- read.csv(paste(dir, f, sep=""), header=F, sep="\t", na.strings="",
                  col.names=c("customerId2", "productId", "divisionId", "sourceId", "itemQty", 
                              "signalDate", "receiptId", "price"),
                  colClasses=c("integer", "integer", "factor", "factor", "integer", 
                               "Date", "integer", "numeric"))
  data_receipts <- rbind(data_receipts, dat)
}

dir <- "../data/sessionsummary/"
file_list <- list.files(dir)
data_session <- NULL
for (f in file_list) {
  dat <- read.csv(paste(dir, f, sep=""), header=F, sep="\t", na.strings=c("", "\\N"),
                  col.names=c("customerId2", "country", "startTime", "site", "pageViewCount", 
                              "nonPageViewEventsCount", "userAgent", "screenResolution", "browserSize", 
                              "productViewCount", "productViewsDistinctCount", "productsAddedToBagCount", 
                              "productsSavedForLaterFromProductPageCount", "productsSavedForLaterFromCategoryPageCount", 
                              "productsPurchasedDistinctCount", "productsPurchasedTotalCount"),
                  colClasses=c("integer", "factor", "Date", "factor", "integer", 
                               "integer", "character", "character", "character",
                               "integer", "integer", "integer", 
                               "integer", "integer", 
                               "integer", "integer"))
  data_session <- rbind(data_session, dat)
}

return(list(customer=data_customer, receipts=data_receipts, 
            returns=data_returns, session=data_session))

}
