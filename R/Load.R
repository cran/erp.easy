#' Import your individual ERP data files.
#'
#' \code{load.data} imports your individual ERP data files. File extensions should be .txt and
#' file names must be in the format: trial.type_sub# (e.g., Neutral_1). Raw data files to be
#' imported should be organized as follows:
#' \itemize{
#'   \item each electrode should be a separate column
#'   \item voltages at each time point should be listed under the appropriate electrode
#'     column as rows
#'  \item no other data should be present in the raw data file (e.g., subject, condition,
#'    time, etc.)
#' }
#'
#' @param path The folder path containing your ERP files
#' @param condition In quotes, a string indicating which trial
#' type you will be importing (i.e., the condition indicated in the file name)
#' @param num.subs The number of files (subjects) to import for a given condition
#' @param epoch.st The earliest time point sampled in the ERP files, including
#'   the basline (e.g., -100)
#' @param epoch.end The final time point sampled in the ERP files
#' @param head Only accepts values of TRUE or FALSE. Used to specify whether or not there
#'   is an existing header row in the ERP files.  If there is no header, \code{load.data}
#'   will supply one.
#' @param addto An existing data frame (i.e. already in the format returned by
#'   \code{load.data}) you wish to add to.  For example, use \code{addto} if you import
#'   a "Neutral" condition, then wish to add a "Standard" condition to the data frame for
#'   analysis. The default value is NULL.
#' @param ext The file extension of the ERP files. The default is .txt
#'
#' @details \itemize{
#'   \item Name each individual file following the format mentioned above (e.g., Neutral_1).
#'   \code{load.data} will look for files beginning with \code{condition}, (e.g., Neutral).  Do
#'   not include the underscore "_" as part of \code{condition}.  The convention for subjects
#'   is a capital "S" followed by the subject number provided in the file name
#'   (e.g., S1, S2, etc.). Subjects will be loaded into the "Subject" column of the returned
#'   data frame.
#'
#'   \item If no header is present in the ERP files, one will be supplied, using the standard R
#'   convenction of a capital "V" followed by increasing integers (e.g., V1, V2, V3). Use these
#'   header values to refer to the electrodes.
#'
#'   \item Enter the baseline, if present in your individual files, in \code{epoch.st} (e.g., -100).
#'
#'   \item Once the desired data frames have been loaded, they can be
#'   \href{http://www.statmethods.net/input/exportingdata.html}{exported} as a number of
#'   different file types.
#'
#'   \item The sample rate will be calculated for you, based on the starting (\code{epoch.st})
#'   and ending (\code{epoch.end}) time points of the recording epoch and the number of time
#'   points in a given condition (the number of rows in your file for each condition).
#'}
#'
#' @note Using \code{addto} is a great way to save time. All functions will act on all
#'   conditions included in the data frame you provide. For example, if you'd like to see
#'   all conditions plotted, simply use \code{addto} to make a single data frame to pass to a
#'   plotting function, and you will see all added conditions plotted simultaneously (as
#'   opposed to making several data frames and passing each separately to a function).
#'
#' @return A single, concatenated data frame of all electrode data for all
#'   subjects organized into columns, with three added columns:
#'
#' \enumerate{
#'   \item "Subject" containing repeating subject names
#'   \item "Stimulus" containing repeating condition names (e.g., Neutral)
#'   \item "Time" containing a repeating list of timepoints sampled
#' }
#'
#' @author Travis Moore
#'
#' @examples
#' \dontrun{
#' # Importing data for a condition named "Neutral" (file names: "Neutral_1", "Neutral_2", etc.)
#' Neutral <- load.data(path = "/Users/Username/Folder/", condition = "Neutral",
#' num.subs = 3, epoch.st = -100, epoch.end = 896, head = FALSE, addto = NULL, ext = ".txt)
#'
#' # Adding a condition named "Standard" to the imported "Neutral" data
#' combo <- load.data(path = "/Users/Username/Folder/", condition = "Standard",
#' num.subs = 3, epoch.st = -100, epoch.end = 896, head = FALSE, addto = Neutral, ext = ".txt)
#' }

  # imports data from file named with the convention "condition_#"
load.data <- function(path, condition, num.subs, epoch.st, epoch.end, head = FALSE,
                      addto = NULL, ext = ".txt") {
  oldwd <- getwd()
  on.exit(setwd(oldwd))
  setwd(path)
  data.in <- vector("list")
    for (i in 1:num.subs) {
      data.in[[i]] <- read.table(paste(condition, "_", i, ext, sep = ""), header = head)
    }
  data.df = plyr::ldply(data.in)
  sublist = vector("list")
    for (i in 1:num.subs) {
      sublist[[i]] = c(rep(paste("S", i, sep = ""), (nrow(data.df)/num.subs)))
    }
  sublist = data.frame(matrix(unlist(sublist), ncol = 1))
  all.times = seq(epoch.st, epoch.end, 1)
  number = round(length(all.times)/(nrow(data.df)/num.subs), digits = 0)
  sampled.times = seq(epoch.st, epoch.end, number)
  stimlist = c(rep(condition, nrow(data.df)))
  data.df1 = cbind.data.frame(sublist, stimlist, sampled.times, data.df)
  colnames(data.df1)[1:3] <- c("Subject", "Stimulus", "Time")
    if (!is.null(addto)) {
      data.df2 = rbind.data.frame(addto, data.df1)
      return(data.df2)
    } else {
      return(data.df1)
    }
  setwd(oldwd)
}
