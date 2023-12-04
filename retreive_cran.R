library(dplyr)
library(data.table)
library(rvest)
library(purrr)

all_packages = readLines(con = "https://cran.r-project.org/web/packages/available_packages_by_name.html")
all_packages = paste(all_packages, collapse = "")
all_packages = strsplit(all_packages, split = "<span class=\"CRAN\">") %>%
  unlist() %>%
  strsplit(split = "</span>") %>%
  lapply(function(x){
    x[1]
  }) %>%
  unlist()

all_packages = all_packages[-c(1:27)]

all_packages_url = paste0("https://cran.r-project.org/web/packages/", all_packages, "/index.html")

all_packges_df = data.frame(
  package_name = all_packages,
  url = all_packages_url
)

get_info = function(url){

  cat(paste0("Retreiving info from ", url, "...\n"))
  package_file = read_html(url)

  dependency = package_file %>%
    html_node("td:contains('Depends:') + td") %>%
    html_text()

  author = package_file %>%
    html_node("td:contains('Author:') + td") %>%
    html_text()

  published = package_file %>%
    html_node("td:contains('Published:') + td") %>%
    html_text()

  version = package_file %>%
    html_node("td:contains('Version:') + td") %>%
    html_text()

  package_info = data.frame(
    url = url,
    author = author,
    published = published,
    version = version,
    dependency = dependency
  )

  return(package_info)
}

package_info = map(as.list(all_packges_df[["url"]]), get_info)
package_info = reduce(package_info, rbind.data.frame)
cran_packages = left_join(all_packges_df, package_info, by = "url")

save(cran_packages, file = "cran_packages.rda")


