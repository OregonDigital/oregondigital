# Something on the interwebs said this is how cool kids use jQuery with CoffeeScript.  I really
# want to be one of the cool kids, so here it is.
$ = jQuery

$ ->
  form = $("#ingest-form-container")
  if form.length != 0
    attachVocabularyListeners()
    lockAllControlledVocabularyFields()

    # This is how we ensure whatever state the form starts on, typeaheads are properly set up
    form.find("select.type-selector").change()

# Sets up listeners on the type dropdowns to check for attaching or removing typeaheads
attachVocabularyListeners = () ->
  $(document).on "change", "#ingest-form-container select.type-selector", (event) ->
    input = $(this).closest(".form-fields-wrapper").find("input.value-field")
    checkControlledVocabulary(input, $(this))

# Iterates over all internal fields, locking the surrounding fields for any
# with a value
lockAllControlledVocabularyFields = () ->
  $("input.internal-field").each ->
    input = $(this)
    if (input.val())
      valueField = input.closest(".form-fields-wrapper").find("input.value-field")
      lockControlledVocabularyFields(valueField)

# Looks up the controlled vocabulary URI for the given option
controlledVocabURIFor = (option) ->
  group = option.closest(".form-fields-wrapper").attr("data-group")
  type = option.val()
  return controlledVocabMap[group]?[type]

# Checks the given input/select combination to see if the input needs a typeahead attached
checkControlledVocabulary = (input, select) ->
  input.typeahead("destroy")
  option = select.find("option").filter(":selected")
  uri = controlledVocabURIFor(option)
  if uri
    attachControlledVocabularyTypeahead(option, input, uri)

# Attaches a typeahead to the given input with the given URI, with default
# behaviors and data for our controlled vocabulary system
attachControlledVocabularyTypeahead = (option, input, uri) ->
  input.typeahead([{
    name: option.val()
    remote: {
      url: uri
      wildcard: "VOCABQUERY"
    }
    valueKey: "label"
    limit: 10
  }])

  # Handle selections so we can populate hidden fields and lock the form down
  input.on 'typeahead:selected', (object, datum) ->
    storeControlledVocabularyData(input, datum)
    lockControlledVocabularyFields(input)

storeControlledVocabularyData = (input, datum) ->
  hiddenField = input.closest(".form-fields-wrapper").find("input.internal-field")
  hiddenField.attr("value", datum.id)

# Prevents the type and value from being modified accidentally
lockControlledVocabularyFields = (input) ->
  input.typeahead("destroy")
  selectField = input.closest(".form-fields-wrapper").find("select.type-selector")
  input.attr("readonly", "readonly")
  selectField.attr("readonly", "readonly")

  # This is kind of stupid, but the readonly attribute only applies UI to the
  # field since selects can't be readonly in HTML for some lovely reason
  selectField.find("option:not(:selected)").hide().attr("disabled",true)
