#' Bio diesel and RON 95 consumption
#' 
#' @description 
#' A data frame including a sample of bio diesel and RON 95 consumption in Greece.
#' 
#' @usage DieselbioRon95
#' 
#' @docType data
#' 
#' @format A data frame with 24 observations of 5 columns:
#' \describe{
#'   \item{\code{region}}{factor of Greek regions}
#'   \item{\code{DieselBio_consumption2006}}{metric tons of bio-diesel consumption in 2006}
#'   \item{\code{DieselBio_consumption2016}}{metric tons of bio-diesel consumption in 2016}
#'   \item{\code{RON95_consumption2006}}{metric tons of ron 95 consumption in 2006}
#'   \item{\code{RON95_consumption2016}}{metric tons of ron 95 consumption in 2016}
#'   }
#' 
#' @name DieselbioRon95
#' 
#' @source The original data are available at 
#' \href{<http://www.statistics.gr/>}{Hellenic Statistical Authority}
#' 
NULL
# 
# region=DieselbioRon95$region
# DieselBio_consumption2006=DieselbioRon95$DieselBio_consumption2006
# DieselBio_consumption2016=DieselbioRon95$DieselBio_consumption2016
# RON95_consumption2006=DieselbioRon95$RON95_consumption2006
# RON95_consumption2016=DieselbioRon95$RON95_consumption2016
# 
# qq=cbind.data.frame(region,
#                     DieselBio_consumption2006,
#                     DieselBio_consumption2016,
#                     RON95_consumption2006,
#                     RON95_consumption2016)
# str(qq)
