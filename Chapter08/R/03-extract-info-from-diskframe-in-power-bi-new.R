library(dplyr)
library(disk.frame)

n_cores <- future::availableCores() - 1

setup_disk.frame(workers = n_cores,
                 future_backend = future::cluster)
options(future.globals.maxSize = Inf)

main_path <- 'D:/<your-path>/AirOnTime'

dkf <- disk.frame( paste0(main_path, '/AirOnTime.df') )

mean_dep_delay_df <- dkf %>%
	srckeep(c("YEAR", "MONTH", "DAY_OF_MONTH", "ORIGIN", "DEP_DELAY")) %>%
	group_by(YEAR, MONTH, DAY_OF_MONTH, ORIGIN) %>%
	summarise(avg_delay = mean(DEP_DELAY, na.rm = TRUE)) %>%
	collect()

readr::write_csv(mean_dep_delay_df, file = r'{D:\<your-path>\Chapter08\R\mean_dep_delay_df.csv}', eol = '\r\n')

future:::ClusterRegistry("stop")


