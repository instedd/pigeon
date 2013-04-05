jQuery.fn.pigeonWizard = ->
  this.each (index, wizard) ->
    prevButton = $('<button type="button">Prev</button>')
    nextButton = $('<button type="button">Next</button>')
    pages = $(wizard).find('.pigeon_wizard_page')
    $('<div class="pigeon_wizard_navigation"></div>').append(prevButton).append(nextButton).appendTo(wizard)

    prevActivePage = (page) ->
      page.prevAll('.pigeon_wizard_page:not(.pigeon_disabled)').first()
    nextActivePage = (page) ->
      page.nextAll('.pigeon_wizard_page:not(.pigeon_disabled)').first()
    currentPage = ->
      pages.filter('.active')

    selectPage = (page) ->
      currentPage().removeClass('active')
      page.addClass('active')
      if prevActivePage(page).length > 0
        prevButton.removeAttr('disabled')
      else
        prevButton.attr('disabled', 'disabled')
      if nextActivePage(page).length > 0
        nextButton.removeAttr('disabled')
      else
        nextButton.attr('disabled', 'disabled')
      
    prevButton.click ->
      current = currentPage()
      prev = prevActivePage(current)
      selectPage prev if prev.length > 0

    nextButton.click ->
      current = currentPage()
      next = nextActivePage(current)
      selectPage next if next.length > 0
              
    selectPage pages.first()

jQuery ->
  $('.pigeon.pigeon_wizard').pigeonWizard()

