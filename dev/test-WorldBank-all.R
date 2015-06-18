context("WorldBank all")

data(WorldBank)

wb.all <-
  list(scatter=ggplot()+
         geom_point(aes(life.expectancy, fertility.rate, clickSelects=country,
                        showSelected=year, colour=region, size=population,
                        tooltip=paste(country, "population", population),
                        key=country), # key aesthetic for animated transitions!
                    data=WorldBank)+
         geom_text(aes(life.expectancy, fertility.rate, label=country,
                       showSelected=country, showSelected2=year,
                       key=country), #also use key here!
                   data=WorldBank, chunk_vars=c("year", "country"))+
         scale_size_animint(breaks=10^(5:9))+
         make_text(WorldBank, 55, 9, "year"),
       ts=ggplot()+
         make_tallrect(WorldBank, "year")+
         geom_line(aes(year, life.expectancy, group=country, colour=region,
                       clickSelects=country),
                   data=WorldBank, size=4, alpha=3/5),
       time=list(variable="year",ms=3000),
       bar=ggplot()+
         theme_animint(height=2400)+
         geom_bar(aes(country, life.expectancy, fill=region,
                      showSelected=year, clickSelects=country),
                  data=WorldBank, stat="identity", position="identity")+
         coord_flip(),
       duration=list(year=1000),
       first=list(year=1975, country="United States"),
       title="World Bank data (single selection)")
# build and reload animint
# animint2dir(wb.all, "WorldBank-all-new")
# first run devtools::install_github("tdhock/animint@7e57b1f334327fc4497ced1d833888c047875a70")
animint2dir(wb.all, "WorldBank-all-old")