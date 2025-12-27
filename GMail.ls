
  do ->

    { list-messages } = dependency 'google.GMail'
    { get-object-and-values-from-args: object-and-values } = dependency 'os.shell.Script'

    get-message-resource = ->

      list: (token-type, access-token, ...args) ->

        { object } = object-and-values args ; {  q: q-values, label: labels, spam, trash, count: count-values, skip: skip-values, max-results: max-results-values } = object

        q = void ; count = 10 ; skip = 0 ; max-results = 100

        if q-values isnt void => [ q ] = q-values
        if count-values isnt void => [ count ] = count-values
        if skip-values isnt void => [ skip ] = skip-values ; skip = parse-int skip
        if max-results-values isnt void => [ max-results ] = max-results-values ; max-results = parse-int skip

        if q is void => q = 'in:inbox'

        list-messages token-type, access-token, q, labels, ((spam isnt void) or (trash isnt void)), count, skip, max-results

    ##

    get-gmail-resources = ->

      message: get-message-resource!

    {
      get-gmail-resources
    }