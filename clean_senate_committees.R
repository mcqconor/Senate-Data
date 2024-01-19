library(readxl)
library(tidyverse)
library(xlsx)

modern_committees <- read.csv('modern_committee_assignments.csv')
com_80_102 <- read.csv('80 to 102 committees.csv')
com_103_115 <- read_xls('senate_assignments_103-115-3.xls')

rearrange_name <- function(name) {
  name_parts <- strsplit(name, ", ")[[1]]
  return(paste(name_parts[2], name_parts[1], sep = " "))
}

rearrange_name_103_115 <- function(name) {
  name_parts <- strsplit(name, ", ")[[1]]
  return(paste(substr(name_parts[2], 1, nchar(name_parts[2])-1), name_parts[1], sep = " "))
}

suffix_80_102 <- com_80_102 %>% 
  filter(grepl('II',name) | grepl('Jr.',name)) %>% 
  mutate(
    suffix = trimws(substr(name, nchar(name)-2, nchar(name))),
    adj_name = trimws(substr(name, 1, nchar(name)-3)),
    ordered_name = sapply(adj_name, rearrange_name),
    ordered_name = paste0(ordered_name, ' ',suffix)
  ) %>% 
  select(-name, -suffix, -adj_name) %>% 
  rename(name=ordered_name)

full_com_80_102 <- com_80_102 %>% 
  filter(!grepl('II',name) & !grepl('Jr.',name)) %>% 
  mutate(
    ordered_name = sapply(name, rearrange_name)
  ) %>% 
  select(-name) %>% 
  rename(name=ordered_name) %>% 
  bind_rows(suffix_80_102)

min_103_115 <- com_103_115 %>% 
  select(
    icpsr_id=`ID #`,
    congress=Congress,
    name=Name,
    party_status=`Maj/Min`,
    committee_party_rank=`Rank Within Party`,
    party_code=`Party Code`,
    committee=`Committee Name`,
    state=`State Name`
  ) %>% 
  mutate(
    party = case_when(
      party_code == 100 ~ 'Democrat',
      party_code == 200 ~ 'Republican',
      T ~ 'Independent'
    )
  ) %>% 
  select(-party_code)

suffix_103_115 <- min_103_115 %>% 
  filter(grepl('II',name) | grepl('Jr.',name)) %>% 
  mutate(
    suffix = trimws(substr(name, nchar(name)-2, nchar(name))),
    adj_name = trimws(substr(name, 1, nchar(name)-3)),
    ordered_name = sapply(adj_name, rearrange_name_103_115),
    ordered_name = paste0(ordered_name, ' ',trimws(suffix))
  ) %>% 
  select(-name, -suffix, -adj_name) %>% 
  rename(name=ordered_name)

full_103_115 <- min_103_115 %>% 
  filter(!grepl('II',name) & !grepl('Jr.',name)) %>% 
  mutate(
    ordered_name = sapply(name, rearrange_name)
  ) %>% 
  select(-name) %>% 
  rename(name=ordered_name) %>% 
  bind_rows(suffix_103_115)

bind_rows(full_com_80_102 %>% select(-X), modern_committees) %>% 
  bind_rows(full_103_115) %>% 
  filter(!committee %in% c('Majority leader','Majority whip','Minority leader','Minority whip')) %>% 
  filter(!grepl('Joint',committee)) %>% 
  filter(committee != '') %>% 
  mutate(
    start_year = case_when(
      congress == 80 ~ 1947,
      congress == 81 ~ 1949,
      congress == 82 ~ 1951,
      congress == 83 ~ 1953,
      congress == 84 ~ 1955,
      congress == 85 ~ 1957,
      congress == 86 ~ 1959,
      congress == 87 ~ 1961,
      congress == 88 ~ 1963,
      congress == 89 ~ 1965,
      congress == 90 ~ 1967,
      congress == 91 ~ 1969,
      congress == 92 ~ 1971,
      congress == 93 ~ 1973,
      congress == 94 ~ 1975,
      congress == 95 ~ 1977,
      congress == 96 ~ 1979,
      congress == 97 ~ 1981,
      congress == 98 ~ 1983,
      congress == 99 ~ 1985,
      congress == 100 ~ 1987,
      congress == 101 ~ 1989,
      congress == 102 ~ 1991,
      congress == 103 ~ 1993,
      congress == 104 ~ 1995,
      congress == 105 ~ 1997,
      congress == 106 ~ 1999,
      congress == 107 ~ 2001,
      congress == 108 ~ 2003,
      congress == 109 ~ 2005,
      congress == 110 ~ 2007,
      congress == 111 ~ 2009,
      congress == 112 ~ 2011,
      congress == 113 ~ 2013,
      congress == 114 ~ 2015,
      congress == 115 ~ 2017,
      congress == 116 ~ 2019,
      congress == 117 ~ 2021,
      congress == 118 ~ 2023
    ),
    committee = case_when(
      committee == 'Agriculture, Nutrition and Forestry' ~ 'Agriculture, Nutrition, and Forestry',
      committee == 'Banking, Housing and Urban Affairs' ~ 'Banking, Housing, and Urban Affairs',
      committee == 'Commerce, Science and Transportation' ~ 'Commerce, Science, and Transportation',
      committee == 'Aging (Special Committee)' ~ 'Aging',
      committee == 'Ethics (Special Committee)' ~ 'Ethics',
      committee == 'Indian Affairs (Special Committee)' ~ 'Indian Affairs',
      committee == 'Intelligence (Special Committee)' ~ 'Intelligence',
      committee == 'APPROPRIATIONS' ~ 'Appropriations',
      committee == 'ENVIRONMENT AND PUBLIC WORKS' ~ 'Environment and Public Works',
      committee == 'JUDICIARY' ~ 'Judiciary',
      grepl('Indian',committee) ~ 'Indian Affairs',
      grepl('Aging',committee) ~ 'Aging',
      grepl('Ethics',committee) ~ 'Ethics',
      grepl('Intelligence',committee) ~ 'Intelligence',
      grepl('Veterans',committee) ~ 'Veterans Affairs',
      grepl('VETERANS',committee) ~ 'Veterans Affairs',
      T ~ committee
    ),
    party = case_when(
      party == '' & state == 'MN' ~ 'Democrat', 
      name == 'Robert Humphreys' ~ 'Democrat',
      name == 'James L. Buckley' ~ 'Republican',
      T ~ party
    ),
    name = case_when(
      name == 'Alfonso M. D\'Amato' ~ 'Alfonse M. D\'Amato',
      name == 'Benjamin L. Cardin' ~ 'Benjamin Cardin',
      name == 'Bernard Sanders' ~ 'Bernie Sanders',
      name == 'Carl M. Levin' ~ 'Carl Levin',
      name == 'Charles Ellis (Chuck) Schumer' ~ 'Chuck Schumer',
      name == 'Christopher J. Dodd' ~ 'Christopher Dodd',
      name == 'Charles E. Grassley' ~ 'Chuck Grassley',
      name == 'Claiborne D. Pell' ~ 'Claiborne Pell',
      name == 'Connie Mack' ~ 'Connie Mack III',
      name == 'Dave Durenburger' ~ 'David F. Durenberger',
      name == 'Deborah Ann Stabenow' ~ 'Debbie Stabenow',
      name == 'Edward J. (Ed) Markey' ~ 'Edward Markey',
      name == 'Harry M. Reid' ~ 'Harry Reid',
      name == 'Herbert H. Kohl' ~ 'Herbert Kohl',
      name == 'Howell T. Heflin' ~ 'Howell Heflin',
      name == 'J. Bennet Johnston' ~ 'J. Bennett Johnston Jr.',
      name == 'John A. Barrasso' ~ 'John Barrasso',
      name == 'Joseph R. Biden Jr.' ~ 'Joe Biden',
      name == 'Kirsten E. Gillibrand' ~ 'Kirsten Gillibrand',
      name == 'Larry Craig' ~ 'Larry E. Craig',
      name == 'Larry Pressler' ~ 'Larry L. Pressler',
      name == 'Lindsey O. Graham' ~ 'Lindsey Graham',
      name == 'Max S. Baucus' ~ 'Max Baucus',
      name == 'Michael Bennett' ~ 'Michael Bennet',
      name == 'Michael Dean Crapo' ~ 'Mike Crapo',
      name == 'Patrick J. Leahy' ~ 'Patrick Leahy',
      name == 'Patrick J. Toomey' ~ 'Patrick Toomey',
      name == 'Paul M. Simon' ~ 'Paul Simon',
      name == 'Paul David Wellstone' ~ 'Paul Wellstone',
      name == 'Richard C. Shelby' ~ 'Richard Shelby',
      name == 'Robert J. Dole' ~ 'Robert Dole',
      name == 'Robert P. Casey Jr.' ~ 'Robert Casey Jr.',
      name == 'Roger F. Wicker' ~ 'Roger Wicker',
      name == 'Samuel A. Nunn' ~ 'Sam Nunn',
      name == 'Shelley M. Capito' ~ 'Shelley Moore Capito',
      name == 'Theodore F. Stevens' ~ 'Ted Stevens',
      name == 'Thomas Tillis' ~ 'Thom Tillis',
      name == 'Thomas Richard Carper' ~ 'Thomas Carper',
      name == 'Timothy Kaine' ~ 'Tim Kaine',
      name == 'Tine Smith' ~ 'Tina Smith',
      T ~ name
    ),
    state = ifelse(name == 'Thomas Allen Coburn','OK', state)
  ) %>% 
  filter(name != 'NA Majority leader designee') %>% 
  write.xlsx('committee_assignments_since_80.xlsx')
