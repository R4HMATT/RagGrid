#' Create a HTML widget using the ag-grid library
#'
#' This function creates a HTML widget to display matrix or a dataframe using ag-grid.
#' @param data a dataobject (either a matrix or a dataframe)
#' @param options a list of ag-grid grid options (see
#'   \url{https://www.ag-grid.com/javascript-grid-properties/});
#' @param colOpts a list of ag-grid column options (see
#'   \url{https://www.ag-grid.com/javascript-grid-column-definitions/});
#' @param theme a theme class name that need to be applied for grid (see
#'   \url{https://www.ag-grid.com/javascript-grid-styling//});
#' @param formattingOptions a list of ag-grid column formatting options (see
#'   \url{http://numeraljs.com/#format}) Also see \code{\link{formatColumns}()};
#' @param filterOnSelect specify whether filter is need to be perfromed on selecting a row item
#' @param licenseKey if you wish to use the enterprise version of ag-grid
#' @param sparkLineOptions options for rendering sparkline in the table
#' @param width,height Width/Height in pixels (optional, defaults to automatic
#'   sizing)
#' @param elementId An id for the widget (a random string by default).
#' @import htmlwidgets
#' @importFrom htmltools tags htmlDependency
#' @importFrom stats setNames
#' @examples
#'
#' aggrid(iris)
#' 
#' @export
aggrid <- function(data, options=list(), colOpts=list(), formattingOptions=list(),sparkLineOptions=list(),theme="ag-theme-balham",filterOnSelect=TRUE ,licenseKey=NULL, width = NULL, height = NULL, elementId = NULL) {

  if (crosstalk::is.SharedData(data)) {
    # Using Crosstalk
    key <- data$key()
    group <- data$groupName()
    data <- data$origData()
  } else {
    # Not using Crosstalk
    key <- NULL
    group <- NULL
  }
  rowHeaders = rownames(data)

  if (is.data.frame(data)) {
    data = as.data.frame(data)
  }else{
    if (!is.matrix(data)) stop(
      "'data' must be either a matrix or a data frame"
    )
    data = as.data.frame(data)
  }

  isNumeric = vapply(data, is.numeric, logical(1))
  isNumeric = lapply(split(isNumeric, names(isNumeric)), unname)
  
  deps = list()
  if(!is.null(licenseKey))
    deps = c(deps,list(getDeps("aggrid-enterprise","18.0.1")))

  deps = c(deps, crosstalk::crosstalkLibs())

  #including css
  css_deps <- getDeps("css","18.0.1")
  css_file_name <- paste(theme,".css",sep="")
  if(css_file_name %in%  css_deps[["stylesheet"]]){
    css_deps[["stylesheet"]] <- c(css_file_name)
  }
  else{
    theme = "ag-theme-balham";
    css_deps[["stylesheet"]] <- c("ag-theme-balham.css")
  }
  deps = c(deps, list(css_deps))

  

  # forward options using x
  x = list(
    data = data,
    gridOptions=options,
    licenseKey=licenseKey,
    isNumeric=isNumeric,
    colOpts=colOpts,
    formattingOptions=formattingOptions,
    theme=theme,
    sparkLineOptions=sparkLineOptions,
    filterOnSelect=filterOnSelect,
    settings = list(
      crosstalk_key = key,
      crosstalk_group = group
    ),
    rowHeaders = rowHeaders
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'RagGrid',
    x,
    width = width,
    height = height,
    package = 'RagGrid',
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      knitr.figure = FALSE, knitr.defaultWidth = "100%", knitr.defaultHeight = "auto"
    ),
    dependencies = deps
  )
}
#' Dependency Path
#' @param ... plugin
depPath = function(...) {
  system.file('htmlwidgets', 'lib', ..., package = 'RagGrid')
}

#' Get dependencies
#' @param plugin plugin
#' @param version version
getDeps = function(plugin,version) {
  d = depPath(plugin)
  htmlDependency(
     tolower(plugin), version, src = d,
    script = list.files(d, '[.]js$'), stylesheet = list.files(d, '[.]css$')
  )
}

#' Shiny bindings for RagGrid
#'
#' Output and render functions for using RagGrid within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a RagGrid
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name RagGrid-shiny
#'
#' @export
RagGridOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'RagGrid', width, height, package = 'RagGrid')
}

#' @rdname RagGrid-shiny
#' @export
renderRagGrid <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, RagGridOutput, env, quoted = TRUE)
}
