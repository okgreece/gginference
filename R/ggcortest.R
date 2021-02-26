#' @title
#' Plot test for association between paired samples
#'
#' @description
#' Visualise test for association between paired samples,
#' using Pearson's product moment correlation coefficient.
#'
#' @usage ggcortest(t, colaccept="lightskyblue1", colreject="grey94",
#' colstat="navy")
#'
#' @param t a list result of \code{\link{cor.test}} of "htest" class
#' @param colaccept color the acceptance area of the test
#' @param colreject color for the rejection area of the test
#' @param colstat color for the test statistic vline
#'
#' @importFrom rlang .data
#' @import ggplot2
#'
#' @rdname ggcortest
#'
#' @export
#'
#' @examples
#'
#' corr_test <- cor.test(iris$Sepal.Length, iris$Sepal.Width)
#' corr_test
#' ggcortest(corr_test)
ggcortest <- function(t,
                      colaccept = "lightskyblue1",
                      colreject = "grey94",
                      colstat = "navy") {
  if (t$method == "Pearson's product-moment correlation") {
    if (abs(t$statistic) > 4) {
      points <- seq(
        from = -1 - abs(t$statistic),
        to = 1 + abs(t$statistic),
        length = 100
      )
    } else {
      points <- seq(-4, 4, length = 100)
    }
    # from t distriution
    df <- t$parameter # degrees of freedom
    level <- 1 - as.numeric(attributes(t$conf.int))

    # set bounds and limit points
    ub <- abs(stats::qt(p = level / 2, df = df, lower.tail = FALSE))
    lb <- -abs(ub)
    limits <- points >= lb & points <= ub

    # gg dataframes
    dfpoly <- data.frame(
      x = c(lb, points[limits], ub),
      y = c(0, stats::dt(points[limits], df = df), 0)
    )

    dfpoly2 <- data.frame(
      x = c(lb, points, ub),
      y = c(0, stats::dt(points, df = df), 0)
    )

    # and plot
    ggplot(data = data.frame(points), aes(points)) +
      stat_function(
        fun = stats::dt,
        n = 101,
        args = list(df = df),
        col = "grey"
      ) +
      geom_polygon(
        data = dfpoly2,
        aes(x, y),
        fill = colreject
      ) +
      geom_polygon(
        data = dfpoly,
        aes(x, y),
        fill = colaccept
      ) +
      labs(
        title = "Student's t distribution Vs test statistic",
        subtitle = "Alternative hypothesis: Two sided",
        x = paste("t-distribution with", df, "degrees of freedom")
      ) +
      scale_y_continuous(breaks = NULL) +
      ylab("") +
      # add the statistics line
      geom_segment(
        aes(
          x = t$statistic,
          y = 0,
          xend = t$statistic,
          yend = 0.39
        ),
        col = colstat
      ) +
      geom_text(
        aes(
          x = t$statistic,
          y = 0.4,
          label = round(t$statistic, 4)
        ),
        colour = colstat
      ) +
      theme_classic()
  }
}
