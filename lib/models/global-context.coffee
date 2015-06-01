helpers = require '../helpers.coffee'
{Emitter, Disposable} = require 'event-kit'

module.exports =
class GlobalContext
  atom.deserializers.add(this)
  # @version = '1a'
  constructor: ->
    @emitter = new Emitter
    @breakpoints = []
    @watchpoints = []
    @debugContexts = []

    @onSessionEnd () =>
      delete @debugContexts[0]
      @debugContexts = []

  serialize: -> {
    deserializer: 'GlobalContext'
    data: {
      version: @constructor.version
      breakpoints: helpers.serializeArray(@getBreakpoints())
      watchpoints: helpers.serializeArray(@getWatchpoints())
    }
  }

  @deserialize: ({data}) ->
    context = new GlobalContext()
    breakpoints = helpers.deserializeArray(data.breakpoints)
    context.setBreakpoints(breakpoints)
    watchpoints = helpers.deserializeArray(data.watchpoints)
    context.setWatchpoints(watchpoints)
    return context

  addBreakpoint: (breakpoint) ->
    helpers.insertOrdered  @breakpoints, breakpoint
    data = {
      added: [breakpoint]
    }
    @notifyBreakpointsChange(data)

  removeBreakpoint: (breakpoint) ->
    removed = helpers.arrayRemove(@breakpoints, breakpoint)
    data = {
      removed: [removed]
    }
    @notifyBreakpointsChange(data)
    return removed

  setBreakpoints: (breakpoints) ->
    removed = @breakpoints
    @breakpoints = breakpoints
    data = {
      added: breakpoints
      removed: removed
    }
    @notifyBreakpointsChange(data)

  setWatchpoints: (watchpoints) ->
    @watchpoints = watchpoints
    data = {
      added: watchpoints
    }
    @notifyWatchpointsChange()

  getBreakpoints: ->
    return @breakpoints

  addDebugContext: (debugContext) ->
    @debugContexts.push debugContext

  getCurrentDebugContext: () =>
    return @debugContexts[0]

  addWatchpoint: (watchpoint) ->
    helpers.insertOrdered  @watchpoints, watchpoint
    @notifyWatchpointsChange()

  getWatchpoints: ->
    return @watchpoints

  setContext: (context) ->
    @context = context

  getContext: ->
    return @context

  clearContext: ->


  onBreakpointsChange: (callback) ->
    @emitter.on 'php-debug.breakpointsChange', callback

  notifyBreakpointsChange: (data) ->
    @emitter.emit 'php-debug.breakpointsChange', data

  onWatchpointsChange: (callback) ->
    @emitter.on 'php-debug.watchpointsChange', callback

  notifyWatchpointsChange: (data) ->
    @emitter.emit 'php-debug.watchpointsChange', data

  onBreak: (callback) ->
    @emitter.on 'php-debug.break', callback

  notifyBreak: (data) ->
    @emitter.emit 'php-debug.break', data

  onContextUpdate: (callback) ->
    @emitter.on 'php-debug.contextUpdate', callback

  notifyContextUpdate: (data) ->
    @emitter.emit 'php-debug.contextUpdate', data

  onSessionEnd: (callback) ->
    @emitter.on 'php-debug.sessionEnd', callback

  notifySessionEnd: (data) ->
    @emitter.emit 'php-debug.sessionEnd', data

  onSessionStart: (callback) ->
    @emitter.on 'php-debug.sessionStart', callback

  notifySessionStart: (data) ->
    @emitter.emit 'php-debug.sessionStart', data

  onRunning: (callback) ->
    @emitter.on 'php-debug.running', callback

  notifyRunning: (data) ->
    @emitter.emit 'php-debug.running', data
