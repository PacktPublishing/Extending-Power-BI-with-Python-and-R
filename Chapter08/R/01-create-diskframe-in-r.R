library(dplyr)
library(disk.frame)

n_cores <- future::availableCores() - 1

setup_disk.frame(workers = n_cores)
options(future.globals.maxSize = Inf)

main_path <- 'D:/<your-path>/AirOnTime'

air_files <- list.files( paste0(main_path, '/AirOnTimeCSV'), full.names=TRUE )

start_time <- Sys.time()
dkf <- csv_to_disk.frame(
    infile = air_files,
    outdir = paste0(main_path, '/AirOnTime.df'),
    select = c('YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY')
)
end_time <- Sys.time()

(create_dkf_exec_time <- end_time - start_time)

future:::ClusterRegistry("stop")
