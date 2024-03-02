#' fast_ifelse
#'
#' @param test to test
#' @param yes output if yes
#' @param no output if no
#'
#'
fast_ifelse <- function(test, yes, no) {
  out <- rep(NA, length(test))
  out[test] <- yes
  out[!test] <- no

  out
}
