library(tidyverse)
library(lubridate)
library(progress)
library(DBI)
library(RMySQL)

# Set a seed
set.seed(23)

# Define the IAP names, types, available denominations, and prices for each;
# For each IAP, there a probabilities for purchasing each denominations;
# The `popularity` is a 1:5 scale of overall preference for purchasing the IAP
iaps <-
  dplyr::tribble(
    ~name,            ~type,  ~size,  ~iap_price, ~size_p, ~popularity,
    "gold1",     "currency",    "1",        0.99,   0.182,          4L,
    "gold2",     "currency",    "2",        1.99,     0.4,          4L,
    "gold3",     "currency",    "3",        4.99,     0.3,          4L,
    "gold4",     "currency",    "4",       19.99,     0.1,          4L,
    "gold5",     "currency",    "5",       28.99,    0.01,          4L,
    "gold6",     "currency",    "6",       59.99,   0.005,          4L,
    "gold7",     "currency",    "7",      119.99,   0.003,          4L,
    "gems1",     "currency",    "1",        2.49,   0.365,          3L,
    "gems2",     "currency",    "2",        9.99,     0.4,          3L,
    "gems3",     "currency",    "3",       24.99,     0.2,          3L,
    "gems4",     "currency",    "4",       59.99,    0.03,          3L,
    "gems5",     "currency",    "5",      129.99,   0.005,          3L,
    "offer1", "offer_agent",    "1",        4.99,     0.3,          1L,
    "offer2", "offer_agent",    "2",        9.99,     0.2,          1L,
    "offer3", "offer_agent",    "3",       14.99,     0.2,          1L,
    "offer4", "offer_agent",    "4",       19.99,     0.2,          1L,
    "offer5", "offer_agent",    "5",       28.99,     0.1,          1L,
    "pass",   "season_pass",    "1",        4.99,     1.0,          5L,
  )

# Exceptional days with rate multipliers
exceptional_tbl <-
  dplyr::tribble(
    ~date,        ~l_idx, ~d_idx, ~r_idx,
    "2015-01-01", 1.1,    1.5,    1.3, # New Year's day
    "2015-01-15", 1.2,    1.2,    1.1, # mid-month
    "2015-02-01", 1.5,    2.1,    1.2, # Super Bowl XLIX
    "2015-02-14", 0.9,    1.2,    1.0, # Valentine's Day
    "2015-02-15", 1.3,    1.6,    1.6, # mid-month
    "2015-04-01", 1.0,    1.2,    1.2, # first day of month
    "2015-05-15", 1.2,    1.4,    1.5, # mid-month
    "2015-06-01", 1.0,    1.3,    1.2, # first day of month
    "2015-06-15", 1.0,    1.4,    1.5, # mid-month
    "2015-07-01", 1.1,    1.3,    1.2, # first day of month
    "2015-07-03", 1.1,    1.5,    1.3, # Independence Day (observed)
    "2015-07-04", 1.2,    2.0,    1.4, # Independence Day
    "2015-07-15", 1.0,    1.4,    1.5, # mid-month
    "2015-08-01", 1.1,    1.3,    1.1, # first day of month
    "2015-08-15", 1.1,    1.3,    1.3, # mid-month
    "2015-09-01", 1.1,    1.2,    1.1, # first day of month
    "2015-09-15", 1.1,    1.2,    1.3, # mid-month
    "2015-09-16", 1.1,    1.1,    1.2, # mid-month
    "2015-10-01", 1.3,    1.4,    1.3, # first day of month
    "2015-10-15", 1.4,    1.3,    1.3, # mid-month
    "2015-10-31", 1.7,    1.2,    1.9, # Halloween
    "2015-11-26", 1.6,    2.5,    1.9, # Thanksgiving
    "2015-11-27", 1.2,    2.2,    1.8, # Black Friday
    "2015-12-01", 1.2,    1.2,    1.4, # first day of month
    "2015-10-15", 1.4,    1.5,    1.3, # mid-month
    "2015-12-24", 1.5,    2.1,    1.5, # Christmas Eve
    "2015-12-25", 1.5,    2.1,    1.7, # Christmas day
    "2015-12-26", 1.5,    2.1,    1.9, # Day after Christmas
    "2015-12-27", 1.5,    2.1,    1.8, # Christmas Break
    "2015-12-28", 1.5,    2.1,    1.7, # Christmas Break
    "2015-12-29", 1.5,    2.1,    1.8, # Christmas Break
    "2015-12-30", 1.5,    2.1,    1.9, # Christmas Break
    "2015-12-31", 1.5,    2.1,    1.2, # New Year's Eve
  )

country_metadata <-
  dplyr::tribble(
    ~country_name,   ~currency, ~ratio_usd, ~ratio_ad,  ~user_count,
    "United States", "USD",      1.0,       1.0,        375000,
    "Canada",        "CAD",      1.0,       1.0,        10000,
    "Australia",     "AUD",      1.0,       1.0,        10000,
    "Mexico",        "MXN",      0.7,       0.6,        8000,
    "United Kingdom","GBP",      1.3,       1.0,        67000,
    "France",        "EUR",      1.2,       1.0,        59000,
    "Germany",       "EUR",      1.2,       1.0,        50000,
    "Spain",         "EUR",      1.1,       0.9,        28000,
    "Portugal",      "EUR",      1.0,       0.9,        25000,
    "Austria",       "EUR",      1.2,       1.0,        11500,
    "Switzerland",   "CHF",      1.4,       1.2,        10000,
    "Denmark",       "DKK",      1.4,       1.1,        4000,
    "Sweden",        "SEK",      1.3,       1.1,        1000,
    "Norway",        "NOK",      1.4,       0.9,        1000,
    "China",         "CNY",      0.7,       0.6,        50000,
    "Hong Kong",     "HKD",      0.9,       0.7,        7000,
    "Philippines",   "PHP",      0.6,       0.4,        25000,
    "Russia",        "RUB",      0.7,       0.3,        40000,
    "India",         "INR",      0.7,       0.2,        52000,
    "Japan",         "JPY",      1.2,       0.6,        68000,
    "South Korea",   "KRW",      1.1,       0.7,        43000,
    "South Africa",  "ZAR",      1.0,       0.7,        10000,
    "Egypt",         "EGP",      0.8,       0.5,        9000,
  )

device_tbl <-
  dplyr::tribble(
    ~platform,   ~device,
    "apple",     "iPhone 4",
    "apple",     "iPhone 4S",
    "apple",     "iPhone 5",
    "apple",     "iPhone 5",
    "apple",     "iPhone 5",
    "apple",     "iPhone 6",
    "apple",     "iPhone 6 Plus",
    "apple",     "iPhone 6s",
    "apple",     "iPhone 6s Plus",
    "apple",     "2nd Gen iPad",
    "apple",     "3rd Gen iPad",
    "apple",     "iPad mini",
    "apple",     "4th Gen iPad",
    "apple",     "3rd Gen iPod",
    "apple",     "4th Gen iPod",
    "apple",     "5th Gen iPod",
    "android",   "Samsung Galaxy A3",
    "android",   "Samsung Galaxy A5",
    "android",   "Samsung Galaxy A7",
    "android",   "Samsung Galaxy S6",
    "android",   "Samsung Galaxy Note 4",
    "android",   "Samsung Galaxy Alpha",
    "android",   "Samsung Galaxy E5",
    "android",   "Samsung Galaxy S6 Edge",
    "android",   "Sony Experia Z5",
    "android",   "Sony Experia Z3",
    "android",   "Sony Experia Z3 Compact",
    "android",   "Sony Experia T3",
    "android",   "Sony Experia M2",
    "android",   "Sony Experia M2 Aqua",
    "android",   "Sony Experia E4",
    "android",   "Sony Experia Z1",
    "android",   "Sony Experia Z1 Compact",
    "android",   "Sony Experia Z2 Tablet",
  )

total_users <- sum(country_metadata$user_count)
countries <- country_metadata$country_name
user_counts <- country_metadata$user_count
user_ids <- replicate(total_users, paste(sample(LETTERS, 12, replace = FALSE), collapse = ""))
platforms <- replicate(total_users, sample(c("apple", "android"), 1, replace = FALSE, prob = c(0.2, 0.8)))

apple_devices <- device_tbl %>% dplyr::filter(platform == "apple") %>% dplyr::pull(device)
android_devices <- device_tbl %>% dplyr::filter(platform == "android") %>% dplyr::pull(device)
acquistion_types_vec <- c("facebook", "google", "apple", "other_campaign", "crosspromo", "organic")
acquistion_probs_vec <- c(0.1, 0.15, 0.05, 0.1, 0.05, 0.55)

devices <-
  vapply(
    platforms, 
    FUN.VALUE = character(1), USE.NAMES = FALSE,
    FUN = function(x) {
      if (x == "apple") {
        sample(apple_devices, 1, replace = FALSE)
      } else {
        sample(android_devices, 1, replace = FALSE)
      }
    }
  )

acquisition_types <-
  vapply(
    seq(total_users), 
    FUN.VALUE = character(1), USE.NAMES = FALSE,
    FUN = function(x) {
      sample(acquistion_types_vec, size = 1, prob = acquistion_probs_vec, replace = FALSE)
    }
  )


user_id_df <- 
  seq(countries) %>%
  purrr::map_df(
    .f = function(x) {
      dplyr::tibble(
        country = countries[x],
        user_number = 1:user_counts[x]
      )
    }
  ) %>%
  dplyr::mutate(user_number_global = 1:n()) %>%
  dplyr::mutate(user_id = user_ids[user_number_global]) %>%
  dplyr::select(user_id, country) %>%
  dplyr::mutate(
    platform = platforms,
    device = devices,
    acquired = acquisition_types
  )
  
# Function to make changes to days based on exceptional circumstances
apply_exceptional_days <- function(purchases_year_df,
                                   exceptional_df) {
  
  for (i in seq(nrow(exceptional_df))) {
    
    day_changes <-
      exceptional_df[i, ] %>%
      as.list()
    
    purchases_year_df <-
      purchases_year_df %>%
      dplyr::mutate(n = ifelse(
        date == day_changes$date &
          purchase_type == "daily_midday_purchases",
        floor(n * day_changes$l_idx),
        n)
      ) %>%
      dplyr::mutate(n = ifelse(
        date == day_changes$date &
          purchase_type == "daily_lateday_purchases",
        floor(n * day_changes$d_idx),
        n)
      ) %>%
      dplyr::mutate(n = ifelse(
        date == day_changes$date &
          purchase_type == "daily_random_purchases",
        floor(n * day_changes$r_idx),
        n)
      )
  }
  
  purchases_year_df
}

# Function to randomly choose `n` iaps and a
# size for a given date and time
randomly_choose_iaps <- function(date,
                                 time,
                                 n = 1,
                                 user_id_df) {

  iap_list <-
    iaps %>%
    dplyr::select(name, popularity) %>%
    dplyr::distinct()
  
  user_purchased <- sample(user_id_df$user_id, 1)

  seq(n) %>%
    purrr::map_df(.f = function(x) {
      
      iap_gotten <-
        sample(
          iap_list$name,
          size = 1,
          prob = iap_list$popularity
        )
      
      size_list <-
        iaps %>%
        dplyr::filter(name == iap_gotten) %>%
        dplyr::select(size, size_p)
      
      size_gotten <-
        sample(
          size_list$size,
          size = 1,
          prob = size_list$size_p
        )
      
      tibble(
        user_id = user_purchased,
        date_time = paste0(date, "-", time),
        date = date,
        time = time,
        name = iap_gotten,
        size = size_gotten
      )
    })
}

# Function to determine how many extra IAPs are part of the
# same purchase depending on `when`
extra_iaps <- function(when = "midday") {
  
  if (when == "midday" || when == "whenever") {
    prob <- c(0.7, 0.2, 0.05, 0.05)
  } else if (when == "lateday") {
    prob <- c(0.6, 0.2, 0.15, 0.05)
  }
  
  sample(0:3, size = 1, prob = prob)
}

# Function to convert fractional 24-h time to proper
# 24-h time strings
convert_time <- function(frac_time) {
  
  hours <- floor(frac_time)
  min_frac <- (frac_time %% 1) * 60
  minutes <- floor(min_frac)
  sec_frac <- (min_frac %% 1) * 60
  seconds <- floor(sec_frac)
  
  hours <- ifelse(hours < 10, paste0("0", hours), as.character(hours))
  minutes <- ifelse(minutes < 10, paste0("0", minutes), as.character(minutes))
  seconds <- ifelse (seconds < 10, paste0("0", round(seconds, 0)), as.character(round(seconds, 0)))
  
  paste(hours, minutes, seconds, sep = ":")
}

next_random_factory <- function(closing_time, mean, sd) {
  
  function() {
    while(TRUE) {
      ret <- rnorm(1, mean = mean, sd = sd)
      if (ret < closing_time) {
        return(ret)
      }
    }
  }
}

# Function to generate a tibble of `n` iap purchases for the lateday period
lateday_purchases <- function(date,
                              busy_night = TRUE,
                              n,
                              user_id_df) {
  
  if (busy_night) {
    next_random <- next_random_factory(23.9, 19, 2.5)
  } else {
    next_random <- next_random_factory(23.9, 18, 2)
  }
  
  seq(n) %>%
    purrr::map_df(.f = function(x) {
      
      time <-
        next_random() %>%
        convert_time()
      
      p_count <- 1 + extra_iaps(when = "lateday")
      
      randomly_choose_iaps(
        date = date,
        time = time,
        n = p_count,
        user_id_df = user_id_df
      )
    })
}

# Function to generate a tibble of `n` IAP purchases for the midday time period
midday_purchases <- function(date,
                             busy_day = TRUE,
                             n,
                             user_id_df) {
  
  if (busy_day) {
    hours <- rnorm(500, mean = 12.5, sd = 1)
    hours <- hours[hours > 0.1]
  } else {
    hours <- rnorm(500, mean = 12.5, sd = 1.5)
    hours <- hours[hours > 0.1]
  }
  
  seq(n) %>%
    purrr::map_df(.f = function(x) {
      
      time <-
        sample(hours, 1) %>%
        convert_time()
      
      p_count <- 1 + extra_iaps(when = "midday")
      
      randomly_choose_iaps(
        date = date,
        time = time,
        n = p_count,
        user_id_df = user_id_df
      )
    })
}

# Function to generate a tibble of `n` IAP purchases randomly
# throughout the day
daily_random_purchases <- function(date,
                                   n,
                                   user_id_df) {
  
  seq(n) %>%
    purrr::map_df(.f = function(x) {
      
      time <-
        runif(1, min = 13, max = 22.5) %>%
        convert_time()
      
      p_count <- 1 + extra_iaps(when = "whenever")
      
      randomly_choose_iaps(
        date = date,
        time = time,
        n = p_count,
        user_id_df = user_id_df
      )
    })
}

# Function to generate a tibble of `n` IAP purchases for
# group functions (these are intermittant, large purchases)
group_purchases <- function(date, n, user_id_df) {
  
  hours <- rnorm(500, mean = 13.0, sd = 1.0)
  hours <- hours[hours > 0.1]
  
  seq(n) %>%
    purrr::map_df(.f = function(x) {
      
      time <-
        sample(hours, 1) %>%
        convert_time()
      
      p_count <- sample(c(5:15), 1)
      
      randomly_choose_iaps(
        date = date,
        time = time,
        n = p_count,
        user_id_df = user_id_df
      )
    })
}

# Function to get a tibble of IAP purchases for a given date,
# based on daily numbers for each period and whether the periods
# are considered busy or not
purchases_for_day <- function(date,
                              n_lateday,
                              n_midday,
                              n_random,
                              busy_day,
                              busy_night,
                              user_id_df) {
  
  dplyr::bind_rows(
    lateday_purchases(
      date = date,
      busy_night = busy_night,
      n = n_lateday,
      user_id_df = user_id_df
    ),
    midday_purchases(
      date = date,
      busy_day = busy_day,
      n = n_midday,
      user_id_df = user_id_df
    ),
    daily_random_purchases(
      date = date,
      n = n_random,
      user_id_df = user_id_df
    )
  )
}

# Function to get a tibble of IAP purchases for the entire year;
# this uses the `purchases_year_df` to provide data for repeated calls
# of `purchases_for_day()`
purchases_for_year <- function(purchases_year_df, user_id_df) {

  dates <- unique(purchases_year_df$date)
  
  purchases_year_df <-
    purchases_year_df %>%
    dplyr::arrange(date, purchase_type)
  
  pr <- progress::progress_bar$new(
    format = "[:bar] :percent eta::eta :spin",
    total = length(dates)
  )
  
  dates %>%
    purrr::map_df(.f = function(x) {
      pr$tick()

      filtered_df <-
        purchases_year_df %>%
        dplyr::filter(date == x)
      
      busy_day <-
        filtered_df %>%
        dplyr::pull(busy_day) %>%
        unique()
      
      busy_night <-
        filtered_df %>%
        dplyr::pull(busy_night) %>%
        unique()
      
      n_counts <-
        filtered_df %>%
        dplyr::pull(n)
      
      purchases_for_day(
        date = x,
        n_lateday = n_counts[1],
        n_midday = n_counts[2],
        n_random = n_counts[3],
        busy_day = busy_day,
        busy_night = busy_night,
        user_id_df = user_id_df
      ) %>%
        dplyr::arrange(time)
    })
}

# Set a time origin
origin <- as.Date(paste0(2015, "-01-01"), tz = "UTC") - lubridate::days(1)

# Create a table with purchase numbers for the entire 2015 year
purchases_year <-
  dplyr::tibble(date = as.Date(1:365, origin = origin, tz = "UTC")) %>%
  dplyr::mutate(dow = wday(date, label = TRUE)) %>%
  dplyr::mutate(busy_day = ifelse(!(dow %in% c("Sat", "Sun")), TRUE, FALSE)) %>%
  dplyr::mutate(busy_night = ifelse(dow %in% c("Fri", "Sat"), TRUE, FALSE)) %>%
  dplyr::mutate(
    daily_midday_purchases =
      ifelse(
        busy_day,
        sample(floor(rnorm(100, mean = 600, sd = 3)), n(), replace = TRUE),
        sample(floor(rnorm(100, mean = 400, sd = 2)), n(), replace = TRUE)
      )
  ) %>%
  dplyr::mutate(
    daily_lateday_purchases =
      ifelse(
        busy_night,
        sample(floor(rnorm(100, mean = 750, sd = 3)), n(), replace = TRUE),
        sample(floor(rnorm(100, mean = 550, sd = 2)), n(), replace = TRUE)
      )
  ) %>%
  dplyr::mutate(
    daily_random_purchases =
      sample(floor(rnorm(100, mean = 450, sd = 4)), n(), replace = TRUE)
  ) %>%
  tidyr::gather("purchase_type", "n", daily_midday_purchases:daily_random_purchases) %>%
  dplyr::arrange(date, purchase_type) %>%
  apply_exceptional_days(exceptional_df = exceptional_tbl)

# Get a tibble of purchases for the entire 2015 year
purchase_tbl <- purchases_for_year(purchases_year_df = purchases_year, user_id_df = user_id_df)

n_session_ids <- purchase_tbl$date_time %>% unique() %>% length()
session_ids <- replicate(n_session_ids, paste(sample(letters, 8, replace = FALSE), collapse = ""))


purchase_tbl <-
  purchase_tbl %>%
  dplyr::inner_join(
    iaps %>% dplyr::select(name, size, type, iap_price),
    by = c("name", "size")
  ) %>%
  dplyr::mutate(session_id = paste0(substr(user_id, 1, 5), "_", session_ids[as.numeric(factor(date_time))])) %>%
  dplyr::mutate(date = as.character(date)) %>%
  dplyr::select(user_id, session_id, dplyr::everything()) %>%
  dplyr::select(-date_time) %>%
  dplyr::rename(price = iap_price)


# Create a table with ad view numbers for the entire 2015 year
ad_views_year <-
  dplyr::tibble(date = as.Date(1:365, origin = origin, tz = "UTC")) %>%
  dplyr::mutate(dow = wday(date, label = TRUE)) %>%
  dplyr::mutate(busy_day = ifelse(!(dow %in% c("Sat", "Sun")), TRUE, FALSE)) %>%
  dplyr::mutate(busy_night = ifelse(dow %in% c("Fri", "Sat"), TRUE, FALSE)) %>%
  dplyr::mutate(
    daily_midday_purchases =
      ifelse(
        busy_day,
        sample(floor(rnorm(100, mean = 1200, sd = 3)), n(), replace = TRUE),
        sample(floor(rnorm(100, mean = 900, sd = 2)), n(), replace = TRUE)
      )
  ) %>%
  dplyr::mutate(
    daily_lateday_purchases =
      ifelse(
        busy_night,
        sample(floor(rnorm(100, mean = 1500, sd = 3)), n(), replace = TRUE),
        sample(floor(rnorm(100, mean = 1200, sd = 2)), n(), replace = TRUE)
      )
  ) %>%
  dplyr::mutate(
    daily_random_purchases =
      sample(floor(rnorm(100, mean = 1000, sd = 4)), n(), replace = TRUE)
  ) %>%
  tidyr::gather("purchase_type", "n", daily_midday_purchases:daily_random_purchases) %>%
  dplyr::arrange(date, purchase_type) %>%
  apply_exceptional_days(exceptional_df = exceptional_tbl)

# Get a tibble of ad_views for the entire 2015 year
ad_view_tbl <- purchases_for_year(purchases_year_df = ad_views_year, user_id_df = user_id_df)

set.seed(24)

n_session_ids <- ad_view_tbl$date_time %>% unique() %>% length()
session_ids <- replicate(n_session_ids, paste(sample(letters, 8, replace = FALSE), collapse = ""))

ad_view_tbl <-
  ad_view_tbl %>%
  dplyr::inner_join(
    iaps %>% dplyr::select(name, size, type, iap_price),
    by = c("name", "size")
  ) %>%
  dplyr::mutate(session_id = paste0(substr(user_id, 1, 5), "_", session_ids[as.numeric(factor(date_time))])) %>%
  dplyr::mutate(date = as.character(date)) %>%
  dplyr::select(user_id, session_id, dplyr::everything()) %>%
  dplyr::select(-date_time) %>%
  dplyr::filter(iap_price < 50 & iap_price > 3) %>%
  dplyr::mutate(iap_price = ((iap_price / 30) - 0.04) %>% round(2)) %>%
  dplyr::mutate(name = case_when(
    iap_price < 1 ~ "ad_5sec",
    iap_price < 2 ~ "ad_15sec",
    TRUE ~ "ad_30sec"
  )) %>%
  dplyr::mutate(size = NA) %>%
  dplyr::mutate(type = "ad") %>%
  dplyr::rename(price = iap_price)

revenue_tbl <-
  dplyr::bind_rows(purchase_tbl %>% dplyr::rename(price = iap_price), ad_view_tbl) %>%
  dplyr::arrange(date, time, user_id) %>%
  dplyr::left_join(user_id_df, by = "user_id") %>%
  dplyr::left_join(country_metadata, by = c("country" = "country_name")) %>%
  dplyr::mutate(revenue = case_when(
    type != "ad" ~ ((price * ratio_usd) - ((price * ratio_usd) * 0.3)),
    TRUE ~ price
  )) %>%
  dplyr::mutate(revenue = case_when(
    type == "ad" ~ price * ratio_ad,
    TRUE ~ revenue
  )) %>%
  dplyr::mutate(price = case_when(
    type == "ad" ~ NA_real_,
    TRUE ~ price
  )) %>%
  dplyr::select(-country, -platform, -device, -acquired, -currency, -ratio_usd, -ratio_ad, -user_count)
  

user_tbl <- 
  user_id_df %>%
  dplyr::inner_join(
    revenue_tbl %>%
      dplyr::group_by(user_id) %>%
      arrange(date, time) %>%
      dplyr::filter(row_number() == 1) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(first_login = ymd_hms(paste(date, time))) %>%
      dplyr::select(user_id, first_login),
    by = "user_id"
  ) %>%
  dplyr::left_join(
    revenue_tbl %>%
      dplyr::filter(type != "ad") %>%
      dplyr::group_by(user_id) %>%
      dplyr::filter(row_number() == 1) %>%
      dplyr::ungroup() %>%
      dplyr::select(user_id, first_iap = name),
    by = "user_id"
  ) %>%
  dplyr::left_join(
    revenue_tbl %>%
      dplyr::filter(type != "ad") %>%
      dplyr::group_by(user_id) %>%
      dplyr::summarize(
        iap_revenue = sum(revenue),
        iap_count = n()
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(user_id, iap_revenue, iap_count),
    by = "user_id"
  ) %>%
  dplyr::left_join(
    revenue_tbl %>%
      dplyr::filter(type == "ad") %>%
      dplyr::group_by(user_id) %>%
      dplyr::summarize(
        ad_revenue = sum(revenue),
        ad_count = n()
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(user_id, ad_revenue, ad_count),
    by = "user_id"
  ) %>%
  dplyr::left_join(
    revenue_tbl %>%
      dplyr::filter(type == "season_pass") %>%
      dplyr::select(user_id) %>%
      dplyr::distinct() %>%
      dplyr::mutate(subscriber = 1L),
    by = "user_id"
  ) %>%
  dplyr::mutate(iap_revenue = ifelse(is.na(iap_revenue), 0, iap_revenue)) %>%
  dplyr::mutate(iap_revenue = ifelse(is.na(ad_revenue), 0, ad_revenue)) %>%
  dplyr::mutate(total_revenue = iap_revenue + ad_revenue) %>%
  dplyr::mutate(subscriber = ifelse(is.na(subscriber), 0L, 1L)) %>%
  dplyr::mutate(customer = ifelse(!is.na(first_iap), 1L, 0L)) %>%
  dplyr::select(
    user_id, first_login, iap_count, iap_revenue, ad_count,
    ad_revenue, total_revenue, customer, subscriber,
    first_iap, platform, device, acquired, country
  )

daily_users_tbl <-
  revenue_tbl %>%
  dplyr::select(user_id, session_id, date, time, type, revenue) %>%
  dplyr::mutate(iap_bought = ifelse(type == "ad", 0, 1)) %>%
  dplyr::mutate(ad_view = ifelse(type == "ad", 1, 0)) %>%
  dplyr::mutate(ad_rev = ifelse(type == "ad", revenue, 0)) %>%
  dplyr::mutate(iap_rev = ifelse(type != "ad", revenue, 0)) %>%
  dplyr::group_by(user_id) %>%
  dplyr::arrange(date, time) %>%
  dplyr::mutate(
    iap_count = as.integer(cumsum(iap_bought)),
    ad_count = as.integer(cumsum(ad_view)),
    iap_revenue = cumsum(iap_rev),
    ad_revenue = cumsum(ad_rev),
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(-type, -revenue, -iap_bought, -ad_view, -iap_rev, -ad_rev) %>%
  dplyr::mutate(total_revenue = iap_revenue + ad_revenue) %>%
  dplyr::mutate(
    session_length = replicate(
      n(),
      sample(
        seq(1, 40, 0.2),
        size = 1,
        prob = dgamma(x = seq(1, 40, 0.2), shape = 2, rate = 0.15))
    )
  ) %>%
  dplyr::mutate(session = 1L) %>%
  dplyr::group_by(user_id) %>%
  dplyr::arrange(date, time) %>%
  dplyr::mutate(
    total_sessions = as.integer(cumsum(session)),
    total_time = cumsum(session_length)) %>%
  dplyr::ungroup() %>%
  dplyr::select(-session) %>%
  dplyr::mutate(is_customer = ifelse(iap_count > 0, 1L, 0L)) %>%
  dplyr::mutate(level_reached = as.integer(floor((total_time * 2.5) / 10))) %>%
  dplyr::mutate(level_reached = ifelse(level_reached >= 10L, 10L, level_reached)) %>%
  dplyr::mutate(at_eoc = ifelse(level_reached == 10, 1L, 0L)) %>%
  dplyr::mutate(in_ftue = ifelse(level_reached == 0, 1L, 0L)) %>%
  dplyr::select(
    user_id, session_id, date, time, total_sessions, total_time,
    level_reached, at_eoc, in_ftue,
    is_customer, iap_revenue, ad_revenue, total_revenue, iap_count, ad_count
  ) %>%
  dplyr::arrange(date, time, user_id)

# Convert `date` and `time` columns to `time`
revenue_tbl <- 
  revenue_tbl %>%
  dplyr::mutate(time = lubridate::ymd_hms(paste(date, time))) %>%
  dplyr::select(-date)

daily_users_tbl <- 
  daily_users_tbl %>%
  dplyr::mutate(time = lubridate::ymd_hms(paste(date, time))) %>%
  dplyr::select(-date)

