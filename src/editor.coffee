# values closed over as private local state
currentEditor = null
interpreter = new BiwaScheme.Interpreter (e, state) ->
    # reset the after evaluate, so we only show the error and not the result
    @after_evaluate = ->
    currentEditor.showError(e)

class SchemeEditor
  constructor: (elementToReplace) ->
    @render($(elementToReplace))
    @setUpTextEditor()
    @addButtonEvents()


  setUpTextEditor: ->
    @codeMirror = CodeMirror.fromTextArea(@el.find('textarea').get(0), {mode: 'scheme'})
    @getButtons().hide()


  render: (elementToReplace) ->
    @originalContent = elementToReplace.text()
    @el = $(""""
    <div class="row">
      <span class='span11'>
        <pre><textarea>#{@originalContent}</textarea></pre>
      </span>
      <div class="btn-group offset-half">
        <button class='btn run-btn btn-primary'>Run</button>
        <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
        </button>
        <ul class="dropdown-menu">
          <li><a href="#" class='run-btn'>Run code</a></li>
          <li><a href="#" class='revert-btn'>Revert content</a></li>
        </ul>
      </div>
      <span class='span11 editor-results'></span>
    </div>
    """)
    elementToReplace.replaceWith @el


  addButtonEvents: ->
    # button click events
    @delegateClick(".run-btn", @run)
    @delegateClick(".revert-btn", @revertContent)

    # button hiding behaviour
    @focussed = false
    @codeMirror.setOption 'onFocus', =>
      @focus = true
      @getButtons().fadeIn(500)

    @hover = false
    @el.mouseover =>
      @hover = true

    @codeMirror.setOption 'onBlur', =>
      @focus = false
      @scheduleHideButtons()

    @el.mouseout =>
      @hover = false
      @scheduleHideButtons()


  scheduleHideButtons: ->
    unhide = () =>
      unless @focus or @hover
        @getButtons().fadeOut(500)

    window.setTimeout unhide, 3000


  delegateClick: (sel, callback) ->
    @el.delegate(sel, 'click', callback)


  renderResult: (type, message) ->
    $("""
    <div class="alert alert-#{type}">
      <button type="button" class="close" data-dismiss="alert">x</button>
      #{message}
    </div>
    """)


  appendResult: (type, message) ->
    @el.find('.editor-results').prepend(@renderResult(type, message))


  showError: (e) => @appendResult('error', e.message)


  showResult: (res) => @appendResult('info', res.toString())


  getContent: -> @codeMirror.getValue()


  getButtons: ->
    @buttons ?= @el.find('div.btn-group')


  run: =>
    try
      currentEditor = this
      interpreter.evaluate @getContent(), (result) =>
        @appendResult 'info', result
    finally
      currentEditor = null


  revertContent: =>
    @codeMirror.setValue(@originalContent)



$ ->
  $('tt').each -> new SchemeEditor(this)
