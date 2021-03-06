#' Return individual average raw data and plotted waveforms (optional) for all loaded conditions
#'
#' \code{individual} plots individual, averaged waveforms for each condition present in the
#'   data frame you provide.  Separate plots for each individual can be generated, if specified.
#'
#' @param data A data frame in the format returned from \code{\link{load.data}}
#' @param electrodes A single value or concatenation of several values (to be averaged)
#'   indicating which electrodes to include in generating the plot. At this time, if the
#'   raw data files imported using \code{\link{load.data}}) do not have a header, you
#'   must include a capital "V" in front of the number and enclose each electrode in quotes.
#'   (For example, electrodes = "V78", or electrodes = c("V78", "V76").)
#' @param plots Creates plots of individual averaged data in separate windows. By default,
#'   plots are suppressed, but can be activated by setting \code{plots} to "y".
#'
#' @details \code{individual} will generate individual average data and separate plots of
#'   averaged waveforms (optional) for each subject in the data frame you provide.  Raw data are
#'   organized in columns by subject and condition. Plots will be generated by setting
#'   \code{plots = "y"}.
#'
#'   Single electrodes can be passed to the package functions,
#'   or several electrodes can be provided (i.e., when using dense arrays) and those electrodes
#'   will be averaged together as a single electrode.
#'
#' @return Data frame of individual average data for each subject in each condition.
#'   If \code{plot = "y"}, then multiple plots (1 per subject) will also be generated.
#'
#' @examples
#' # Return data frame of individual average data and create average waveform
#' # plots for each subject
#' individual(ERPdata, electrodes = "V78", plots="y")
#'
#' @author Travis Moore

# function that plots the individual, average waveforms in separate windows
individual <- function(data, electrodes, plots = "n") {
  data.fun <- data
  num.subs <- length(levels(data$Subject))
  sub.IDs <- levels(data$Subject)
  num.conditions <- length(levels(data$Stimulus))
  trial.types <- levels(data$Stimulus)
  stim.block <- length(data$Time)/num.subs
  Stimulus <- data$Stimulus[1:stim.block]
  time.points <- (length(data$Time)/num.subs)/num.conditions  # an integer
  # of the number of time points for one stimulus type for one subject
  Time.range <- data$Time[1:time.points]
    # calls the cluster.seg function
  cluster <- .cluster.seg(data, electrodes)
    # calls the avg.sub function
  avgsub <- .avg.subs(data, electrodes, window, cluster, Time.range, trial.types)
    # extracts grand mean data
  means.cond.sub <- .ind.by.cond(data, electrodes, window, Time.range,
                                  avgsub, trial.types, Stimulus, num.subs, num.conditions)
  m = as.data.frame(means.cond.sub)

  if (plots == "n") {
    # no plots
  } else if (plots == "y") {
  for (i in 1:num.subs) {
    dev.new()
    plot(unlist(m[i]) ~ Time.range,
         typ = "l",
         lwd = 3,
         col = 2,
         ylim = c(min(m),max(m)),
         main = sub.IDs[i],
         ylab = "Amplitude in microvolts",
         xlab = "Time in milliseconds")
    count <- i  # keeps track of how many times the main 'for' loop has run
    # (i.e., which subject number)
    counter <- 3
    for (j in c(seq(count, ncol(m), num.subs))) {
      counter <- counter + 1
      try(  # this catches a known error in creating the individual plots.
        # try() ~ on.error.resume.next from VB
        lines(unlist(m[ (j + num.subs)]) ~ Time.range,
              typ = "l",
              lwd = 3,
              col = counter),
        silent = TRUE)  # silent=TRUE with try() suppresses the error message(s)
    }  # close nested 'for' loop
    try(legend("topright",
           inset = .05,
           title = "Trial Types",
           lwd = 3,
           trial.types,
           col = c(2, 4, seq(5, num.conditions+3, 1)))  # part of MAIN 'for' loop,
    , silent = TRUE) # suppresses a known error when there is only 1 condition
    # so legends are added to each plot
    # (as opposed to after each lines() for conditions)
  }  # close main 'for' loop
  } # close if for plots

  # organize and return individual average data
  name.list <- rep(sub.IDs, num.conditions)
  uscores <- rep("_", length(name.list))
  num.trls <- length(name.list) / num.conditions
  conditions <- vector()
    for (n in 1:num.conditions) {
      conds <- rep(trial.types[n], num.trls)
      conditions <- c(conditions, conds)
    }
  name.list2 <- paste(conditions, uscores, name.list, sep="")
  names(m)[] <- name.list2
  return(m)

}  #close plot.ind()
