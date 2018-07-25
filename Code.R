library(RCurl)
library(tcltk)

# Set working directory to system temp folder
setwd(Sys.getenv("TMP"))

# Specify the WebDAV address
link <- "https://YourWebsite.com/remote.php/webdav/Folder/"

# Get user credentials =========================

## ADAPTED from code by Barry Rowlingson Code 
## Sourced from: https://magesblog.com/post/2014-07-15-simple-user-interface-in-r-to-get-login/
## Original: http://r.789695.n4.nabble.com/tkentry-that-exits-after-RETURN-tt854721.html#none
getLoginDetails <- function() {
    require(tcltk)
    tt <- tktoplevel()
    tkwm.title(tt, "Get login details")
    Name <- tclVar("Login ID")
    Password <- tclVar("Password")
    entry.Name <- tkentry(tt, width = "20", textvariable = Name)
    entry.Password <- tkentry(tt, width = "20", show = "*", textvariable = Password)
    tkgrid(tklabel(tt, text = "Please enter your login details."))
    tkgrid(entry.Name)
    tkgrid(entry.Password)
    
    OnOK <- function() {
        tkdestroy(tt)
    }
    OK.but <- tkbutton(tt, text = " OK ", command = OnOK)
    tkbind(entry.Password, "<Return>", OnOK)
    tkgrid(OK.but)
    tkfocus(tt)
    tkwait.window(tt)
    
    invisible(c(loginID = tclvalue(Name), password = tclvalue(Password)))
}
credentials <- getLoginDetails()
credentials <- unname(credentials, force = FALSE)

## END ADAPATED

# Check to see if the user credentials are valid
# Replace "SAMPLE.csv" with a known file on the server
check <- getURL(paste(link, "SAMPLE.csv", collapse = NULL, sep = ""), userpwd = paste(credentials[1], 
    credentials[2], sep = ":"))
check <- grepl(pattern = "error", check)
while (check == TRUE) {
    check <- getURL(paste(link, "SAMPLE.csv", collapse = NULL, sep = ""), 
        userpwd = paste(credentials[1], credentials[2], sep = ":"))
    check <- grepl(pattern = "error", check)
    if (check == TRUE) {
        credentials <- getLoginDetails()
        credentials <- unname(credentials, force = FALSE)
    }
}

# Access WebDAV ====================================================

# Check to see if a temp .csv file already exists and IFF it exists, delete it.
if (file.exists("temp.csv")) {
    file.remove("temp.csv")
}

# Create a temp file to store the data from the server.
file.create("temp.csv", showWarnings = TRUE)

# Download File via CURL and stream the data directly into a temp file
# Replace "FILE.csv" with the desired file
write(getURL(paste(link, "FILE.csv", collapse = NULL, sep = ""), userpwd = paste(credentials[1], 
    credentials[2], sep = ":")), file = "temp.csv", append = FALSE)
# Import the downloaded file into R
df <<- read.csv("temp.csv", sep = ",", header = TRUE, check.names = FALSE, 
    stringsAsFactors = FALSE, na.strings = c("", "NA"))

## ADAPTED

# Delete credentials #
rm(credentials)

## END ADAPTED
