---
title: Install R packages
author: ''
date: "2020-01-06"
slug: packages
categories: []
tags: []
linktitle: "Install R packages"
menu:
  pre:
    parent: "Local setup"
    weight: 3
toc: yes
type: docs
---



You can download all the R packages we will need as well as download the course materials using the course R package, which you can install from GitHub using the remotes package.


```r
# if needed:
# install.packages("remotes")

remotes::install_github("malcolmbarrett/org.first.r.pkg")
org.first.r.pkg::install_workshop("path/to/download/materials")
```

Installing the workshop materials will open an RStudio project containing all the materials we'll use.

If you prefer to work with the materials via git, you can just install course package without running `install_workshop()`. You can find the materials on the [course GitHub repository](https://github.com/rstudio-conf-2020/my-org-first-pkg).
