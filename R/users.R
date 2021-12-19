# psicotuiterbot-report

library(dplyr)
library(purrr)
library(ggplot2)
library(rtweet)
library(igraph)
library(here)

# create token
my_token <- create_token(
    app = "psicotuiterbot",  # the name of the Twitter app
    consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_KEY_SECRET"),
    access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"), 
    set_renv = FALSE
)


# get bot followers
users_raw <- get_followers("psicotuiterbot", token = my_token, n = 14000)

saveRDS(users_raw, here("data", "followers-bot.rds"))

# get top followers (by N followers)
top_accounts <- users_raw %>% 
    distinct(user_id) %>%
    pull(user_id) %>% 
    lookup_users(token = my_token) %>% 
    pull(screen_name) %>% 
    lookup_users(token = my_token) %>%
    users_data() %>% 
    top_n(n = 10, wt = followers_count) %>% 
    arrange(followers_count) %>% 
    pull(screen_name)

saveRDS(top_accounts, here("data", "followers-bot.rds"))

# get followers of followers
followers <- map(top_accounts, get_followers, n = 14000, token = my_token) %>% 
    set_names(top_accounts) %>% 
    bind_rows(.id = "account")

saveRDS(top_accounts, here("data", "top-followers.rds"))

count(followers, account) %>% 
    ggplot(aes(reorder(account, -n), n)) +
    geom_col()


net <-  network_data(tweets, .e = c("mention, reply, quote"))


plot(
    graph, 
    width = 0.1
    arrow.size = 0.1,
    arrow.width = 0.1,
    shape = "square",
    label.cex = 0.1,
    color = "white",
    label.color = "black"
)
