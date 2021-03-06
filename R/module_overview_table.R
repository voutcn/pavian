#' UI part of report overview module
#'
#' @param id Shiny namespace id.
#'
#' @return UI elements for report overview module.
#' @export
#' @import shiny
reportOverviewModuleUI <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    checkboxInput(ns("opt_samples_overview_percent"), label = "Show percentages instead of number of reads", value = TRUE),
    div(style = 'overflow-x: scroll',
        DT::dataTableOutput(ns('dt_samples_overview')))
  )

}

#' Shiny modules to display an overview of metagenomics reports
#'
#' @param input Shiny input object.
#' @param output Shiyn output object.
#' @param session Shiny session object.
#' @param sample_data Samples \code{data.frame}.
#' @param reports List of reports.
#' @param datatable_opts Additional options for datatable.
#'
#' @return Report overview module server functionality.
#' @export
#' @import shiny
reportOverviewModule <- function(input, output, session, sample_data, reports, datatable_opts = NULL) {
  #r_state <- list()

  observeEvent(input$opt_samples_overview_percent, {
    ## save state of table
    #r_state <<- list(
    #  search_columns = input$dt_samples_overview_search_columns,
    #  state = input$dt_samples_overview_state
    #  )
    # utils::str(input$dt_samples_overview_state)
  })

  get_samples_summary <- reactive( {
    validate(need(sample_data(), message = "No data available."))
    validate(need(reports(), message = "No data available."))

    withProgress({
    ## Create summaries of all reports
    #str(reports())
    samples_summary <- do.call(rbind, lapply(reports(), summarize_report))
    samples_summary$Name <- rownames(samples_summary)
    #samples_summary$FileName <- sample_data()[,"ReportFile"]
    extra_cols <- c("Name")
    samples_summary <- samples_summary[,c(extra_cols, setdiff(colnames(samples_summary),extra_cols))]
    colnames(samples_summary) <- beautify_string(colnames(samples_summary))
    samples_summary
    }, message = "Summarizing sample contents ... ")
  })

  ## Samples overview output
  output$dt_samples_overview <- DT::renderDataTable({

    samples_summary <- get_samples_summary()

    start_color_bar_at <- 2  ## length of extra_cols + 1
    number_range <-  c(0, max(samples_summary[, start_color_bar_at], na.rm = TRUE))

    if (isTRUE(input$opt_samples_overview_percent)) {
      ## add a custom renderer.
      start_color_bar_at <- start_color_bar_at + 1
      number_range <- c(0, 100)
      samples_summary[, start_color_bar_at:ncol(samples_summary)] <-
        100 * signif(sweep(samples_summary[, start_color_bar_at:ncol(samples_summary)], 1, samples_summary[, start_color_bar_at], `/`), 4)

      ## TODO: Define columnDefs and give read counts on mouse-over
    }

    styleColorBar2 = function(data, color, angle=90) {
      rg = range(data, na.rm = TRUE, finite = TRUE)
      r1 = rg[1]; r2 = rg[2]; r = r2 - r1
      htmlwidgets::JS(sprintf(
        "isNaN(parseFloat(value)) || value <= %s ? '' : 'linear-gradient(%sdeg, transparent ' + (%s - value)/%s * 100 + '%%, %s ' + (%s - value)/%s * 100 + '%%)'",
        r1, angle, r2, r, color, r2, r
      ))
    }

    microbial_col <- start_color_bar_at + 5


    dt <- DT::datatable(
      samples_summary
      , rownames = FALSE
      , selection = 'single'
      ,extensions = c('Buttons')
      , options = list(
        dom = 'Bfrtip'
        , buttons = c('pageLength','pdf', 'excel' , 'csv', 'copy', 'colvis')
        , lengthMenu = list(c(10, 25, 100, -1), c('10', '25', '100', 'All'))
        , pageLength = 25
        , options = c(datatable_opts, list(stateSave = TRUE))
      )
    ) %>%
      DT::formatStyle(
        colnames(samples_summary)[seq(from=start_color_bar_at, to=microbial_col-1)],
        background = styleColorBar2(number_range, 'lightblue')
      ) %>%
       DT::formatStyle(colnames(samples_summary)[seq(from=microbial_col,to=ncol(samples_summary))],
                       background = DT::styleColorBar(c(0, max(
                         samples_summary[, microbial_col], na.rm = TRUE
                     )), 'lightgreen'))

    #formatString <- function(table, columns, before="", after="") {
    #  DT:::formatColumns(table, columns, function(col, before, after)
    #    sprintf("$(this.api().cell(row, %s).node()).html((%s + data[%d]) + %s);  ",col, before, col, after),
    #    before, after
    #  )
    #}

     if (isTRUE(input$opt_samples_overview_percent)) {
       dt <- dt %>%
         DT::formatCurrency(start_color_bar_at - 1, currency = '', digits = 0) %>%
         DT::formatString(seq(from=start_color_bar_at, to=ncol(samples_summary)),
                      suffix = '%')  ## TODO: display as percent
    #   ## not implemented for now as formatPercentage enforces a certain number of digits, but I like to round
    #   ## with signif.
     } else {
       dt <-
         dt %>% DT::formatCurrency(seq(from=start_color_bar_at, to=ncol(samples_summary)),
                               currency = '',
                               digits = 0)
     }

    dt
  })

}
