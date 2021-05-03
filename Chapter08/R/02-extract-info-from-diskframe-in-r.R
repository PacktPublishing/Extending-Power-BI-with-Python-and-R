library(dplyr)
library(disk.frame)

n_cores <- future::availableCores() - 1

setup_disk.frame(workers = n_cores)
options(future.globals.maxSize = Inf)

main_path <- 'D:/<your-path>/AirOnTime'

dkf <- disk.frame( paste0(main_path, '/AirOnTime.df') )

start_time <- Sys.time()
mean_dep_delay_df <- dkf %>%
	srckeep(c("YEAR", "MONTH", "DAY_OF_MONTH", "ORIGIN", "DEP_DELAY")) %>%
	group_by(YEAR, MONTH, DAY_OF_MONTH, ORIGIN) %>%
	summarise(avg_delay = mean(DEP_DELAY, na.rm = TRUE)) %>%
	collect()
end_time <- Sys.time()

(aggregate_exec_time <- end_time - start_time)

future:::ClusterRegistry("stop")


