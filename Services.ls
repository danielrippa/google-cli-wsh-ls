
  do ->

    { create-error-context } = dependency 'prelude.error.Context'
    { create-instance } = dependency 'value.Instance'
    { camel-case } = dependency 'value.string.Case'
    { get-gmail-resources } = dependency 'GMail'
    { get-service-access-token } = dependency 'AccessToken'
    { invoke-method } = dependency 'value.Function'
    { object-member-names } = dependency 'value.Object'
    { compose-with } = dependency 'value.instance.Composition'

    { argtype, create-error } = create-error-context 'google-cli.Services'

    create-service = (service-name, resource-implementations) ->

      argtype '<String>' {service-name} ; argtype '<Object>' {resource-implementations}

      instance = create-instance do

        service-name: getter: -> service-name
        resource-names: getter: -> object-member-names resource-implementations

        service-usage: getter: -> [ "<resource-name> <command> [command-args...]", '', "where <resource-name> can be any of #{ @get-resource-names! * ', ' }", "and <command> and <command-args> are resource specific." ]

        invoke-resource-command-with-args: method: (resource-name, command-name, args) ->

          resource = resource-implementations[ resource-name ]
          if resource is void => throw create-error "Invalid resource name '#resource-name' for service '#service-name'. Valid resource-names are: #{ @get-resource-names! * ', ' }."

          command = resource[ command-name ]
          if command is void => throw create-error "Unknown command '#command-name' for resource '#resource-name' of service '#service-name'. Available commands are: #{ (object-member-names resource) }"

          { token-type, access-token } = get-service-access-token service-name

          invoke-method instance, command, [ token-type, access-token ] ++ args

      instance `compose-with` [ resource-implementations ]

    ##

    service-names = <[ gmail ]>

    get-service-implementation = (service-name) ->

      resources-implementation-fn = eval camel-case "get-#{service-name}-resources"
      if (typeof resources-implementation-fn) isnt 'function' => throw create-error "Resources implementation for service '#service-name' not found."

      resources-implementation-fn!

    create-service-manager = ->

      services = { [ (service-name), (create-service service-name, get-service-implementation service-name) ] for service-name in service-names }

      get-service: (service-name) ->

        service = services[ (argtype '<String>' {service-name}) ]
        if service is void => throw create-error "Invalid service name '#service-name'."

        service

    service-manager = void ; get-service-manager = -> (if service-manager is void => service-manager := create-service-manager!) ; service-manager

    {
      get-service-manager
    }