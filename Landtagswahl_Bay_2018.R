

pacman::p_load(rvest, tidyverse, lubridate)


ltw_by <- "https://www.wahlrecht.de/umfragen/landtage/bayern.htm"
page <- read_html(ltw_by)
tbls <- html_nodes(page, "table")




# Umfrage-Daten aller repr�sentativer Umfragen f�r die Landtagswahl in Bayern, entnommen von [wahlrecht.de](https://www.wahlrecht.de/umfragen/landtage/bayern.htm)



tbls_ls <- page %>%
  html_nodes("table") %>%
  .[2:4] %>%
  html_table(fill= T)




parteicolor <- c("black", "red", "green", "yellow",
                 "dark red", "brown", "blue", "purple")

data <- read_html(ltw_by) %>%
  html_nodes(., "table") %>%
  .[2] %>% html_table(trim = T, fill = T) %>%
  .[[1]] %>% .[-1, -5]



data$CSU <- parse_number(data$CSU, locale = locale(grouping_mark = "."))
data$SPD <- parse_number(data$SPD, locale = locale(grouping_mark = "."))
data$GR�NE <- parse_number(data$GR�NE, locale = locale(grouping_mark = "."))
data$FDP <- parse_number(data$FDP, locale = locale(grouping_mark = "."))
data$LINKE <- parse_number(data$LINKE, locale = locale(grouping_mark = "."))
data$FW <- parse_number(data$FW, locale = locale(grouping_mark = "."))
data$AfD <- parse_number(data$AfD, locale = locale(grouping_mark = "."))
data$Sonstige <- parse_number(data$Sonstige, locale = locale(grouping_mark = "."))

data$Datum <- parse_date(data$Datum, "%d.%m.%Y")


data %>% filter(!is.na(Datum)) -> data

data %>% gather(`CSU`, `SPD`, `GR�NE`, `FDP`,
                `LINKE`, `FW`, `AfD`, `Sonstige`, key = "Partei",
                value = "Ergebnis") ->  data_long



data_long %>% ggplot(aes(x = Datum, y = Ergebnis, 
                         color = Partei)) +
  geom_point() +
  geom_smooth(se = F, span = .5, size = 1)+
  scale_color_manual(values = c("blue", "black", "yellow", "lightseagreen",
                                "green",  "red4","grey40", "red")) +
  theme_light() +
  geom_hline(aes(yintercept = min(data$CSU)), linetype = 3)


data_long %>% ggplot(aes(x = month(Datum), y = Ergebnis, 
                         color = Partei)) +
  geom_point() +
  geom_smooth(se = F, span = .5) +
  facet_wrap(~year(Datum), ncol = 2) +
  scale_color_manual(values = c("blue", "black", "yellow", "lightseagreen",
                                "green",  "red4","grey40", "red")) +
  scale_x_continuous(limits = c(1,12), breaks = c(1:12)) +
  theme_light()





## 1-Jahres-Trend



data_long %>%
  filter(Datum >= as.Date(today() - 365)) %>% 
  ggplot(aes(x = Datum, y = Ergebnis, 
             color = Partei)) +
  geom_point() +
  geom_smooth(se = F, span = .3)+
  scale_color_manual(values = c("blue", "black", "yellow", "lightseagreen",
                                "green",  "red4","grey40", "red")) +
  theme_light() +
  labs(title = "1-Jahres-Trend")



### Entwicklung innerhalb der letzten 30 Tage



data_long %>%
  filter(Datum >= as.Date(today() - 30)) %>%
  ggplot(aes(x = Datum, y = Ergebnis, 
             color = Partei)) +
  geom_point() +
  geom_line()+
  scale_color_manual(values = c("blue", "black", "yellow", "lightseagreen",
                                "green",  "red4","grey40", "red")) +
  theme_light() +
  labs(title = "30-Tage-Trend")




## Gibt es Unterschiede hinsichtlich der Auftraggeber?


data_long %>% 
  filter(Datum >= as.Date("2018-01-1")) %>%
  ggplot(aes(x = Datum, y = Ergebnis,
             color = Institut, group = Institut)) +
  geom_point() +
  scale_y_continuous() +
  geom_line() +
  facet_wrap(~ Partei, scales = "free", ncol = 3) +
  theme_light() +
  theme(legend.position = "bottom")


# Bei der CSU und den Gr�nen scheinen sich die Institute einig zu sein. Allerdings gibt es bei anderen Parteien ziemliche Unterschiede:
#   
#   * die AfD schneidet bei INSA-Umfragen konsequent besser ab als bei z.B. FGW-Umfragen oder InfraTest. Der Unterschied ist im Vergleich mit anderen Parteien extrem: 14% vs. 10% sind �berraschend, wenn man die Stichprobengr��en betrachtet. Vielleicht gibt es hier systematische Unterschiede bei der Stichprobenziehung?
#   * bei der FDP gibt es ebenfalls Unterschiede, allerdings sehen diese weniger systematisch aus. Au�erdem sind die Schwankungen mit einem Prozentpunkt vernachl�ssigbar.




## Alle m�gen Pie-Charts


data_long %>%
  group_by(Partei) %>%
  slice(which.max(Datum)) %>%
  ungroup() %>%
  ggplot(aes(x = "", y = Ergebnis, fill = Partei)) +
  geom_bar(width = 1, stat = "identity") +
  scale_fill_manual(values = c("blue", "black", "yellow",
                               "lightseagreen",
                               "green",  "red4","grey40", "red")) +
  theme_light() +
  coord_polar("y") +
  labs(title = max(data_long$Datum))

