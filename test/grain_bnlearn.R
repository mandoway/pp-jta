library(bnlearn)
library(gRain)
library(profmem)

loadRData <- function(fileName){
  #loads an RData file, and returns it
  load(fileName)
  get(ls()[ls() != "fileName"])
}

generate_grain <- function(bayesn) {
  components = list()
  for (node in bayesn) {
    if (length(node$parents) == 0) {
      x = parray(
        node$node,
        levels = dimnames(node$prob),
        values = node$prob
      )
    } else {
      x = parray(
        c(node$node, node$parents),
        levels = dimnames(node$prob),
        values = node$prob
      )
    }
    components[[length(components) + 1]] = x
  }
  
  return(components)
}


run_instance <- function(path) {
  bn <- loadRData(path)
  plist <- generate_grain(bn)
  nodes <- c()
  for (node in bn) {
    nodes <- c(nodes, node$node)
  }
  
  t0 <- Sys.time()
  net <- grain(compileCPT(plist))
  
  querygrain(net, nodes = nodes, type = "marginal")
  t1 <- Sys.time() - t0
  print(paste("Time for instance", path, "=", t1), sep = " ")
  return(t1)
  
}


main <- function(base, instance_set = "small") {
  switch(instance_set,
    small={
      instances <- paste("small", c("asia.rda", "cancer.rda", "earthquake.rda", "sachs.rda", "survey.rda"), sep="/")
    },
    medium={
      instances <- paste("medium", c("alarm.rda", "barley.rda", "child.rda", "insurance.rda", "mildew.rda", "water.rda"), sep="/")
    },
    large={
      instances <- paste("large", c("hailfinder.rda", "hepar2.rda", "win95pts.rda"), sep="/")
    },
    verylarge={
      instances <- paste("verylarge", c("andes.rda", "diabetes.rda", "munin1.rda", "pathfinder.rda", "pigs.rda"), sep="/")
    },
    massive={
      instances <- paste("massive", c("munin.rda", "munin2.rda", "munin3.rda", "munin4.rda"), sep="/")
    },
    link={
      instances <- c("verylarge/link.rda")
    },
    {
      print("Not a valid instance set.")
      stop()
    }
  )
  
  # options(profmem.threshold = 1)
  df <- data.frame("total_mem" = numeric(), "time" = numeric())
  for (instance in paste(base, instances, sep = "")) {
    p <- profmem(
      t1 <- run_instance(instance)
    )
    print(paste("Memory Usage", sum(p$bytes, na.rm = TRUE) / 1e6, "MB", sep = " "))
    df[nrow(df) + 1,] <- c(sum(p$bytes, na.rm = TRUE) / 1e6, t1)
    # run_instance(instance)
  } 
  return(df)
}

profile <- function() {
  Sys.sleep(1)
  run_instance("/home/johannes/Documents/Uni/pp-jta/instances/massive/munin4.rda")
}
profile()
#p <- profmem(
#  run_instance("/home/johannes/Documents/Uni/pp-jta/instances/medium/barley.rda")
#)
# print(paste("Memory Usage", sum(p$bytes, na.rm=TRUE) / 1e6, "MB", sep = " "))

# instance_set <- "massive"
# df <- main("/home/johannes/Documents/Uni/pp-jta/instances/", instance_set)
# write.csv(df, paste(instance_set, ".csv", sep = ""), row.names = FALSE)