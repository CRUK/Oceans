define (require, exports, module) ->
  $ = require 'jQuery'

  config = require 'zooniverse/config'
  ids = require 'ids'

  App = require 'zooniverse/controllers/App'
  Project = require 'zooniverse/models/Project'
  Workflow = require 'zooniverse/models/Workflow'
  Subject = require 'zooniverse/models/Subject'

  Classifier = require 'controllers/Classifier'
  tutorialSteps = require 'tutorialSteps'
  Map = require 'zooniverse/controllers/Map'
  Scoreboard = require 'controllers/Scoreboard'
  Profile = require 'controllers/Profile'
  ImageFlipper = require 'controllers/ImageFlipper'

  # noop = ->
  # window.console ||=
  #   log: noop
  #   debug: noop
  #   info: noop
  #   warn: noop
  #   error: noop

  config.set
    name: 'Seafloor Explorer'
    slug: 'seafloor-explorer'
    description: 'Help explore the ocean floor!'

    domain: 'seafloorExplorer.org'
    talkHost: 'http://talk.seafloorexplorer.org'

    cartoUser: 'the-zooniverse'
    cartoTable: 'seafloor_explorer'

    googleAnalytics: 'UA-1224199-30'

  config.set
    app: new App
      el: '#main'
      appName: 'Seafloor Explorer'
      languages: ['en']

      projects: new Project
        id: ids.project

        workflows: new Workflow
          id: ids.workflow

          tutorialSubjects: new Subject
              id: ids.tutorialSubject
              location:
                standard: "http://www.seafloorexplorer.org/subjects/standard/tutorial.jpg"
                thumbnail: "http://www.seafloorexplorer.org/subjects/standard/tutorial.jpg"
              coords: [0, 0]
              metadata:
                depth: 0
                altitude: 0
                heading: 0
                salinity: 0
                temperature: 0
                speed: 0
                mm_pix: 1

  Map::apiKey = '21a5504123984624a5e1a856fc00e238'
  Map::tilesId = 65990

  config.set
    classifier: new Classifier
      el: '#classifier'
      tutorialSteps: tutorialSteps
      workflow: config.app.projects[0].workflows[0]

    profile: new Profile
      el: '[data-page="profile"]'

    homeMap: new Map
      el: '[data-page="home"] .map'
      latitude: 40
      longitude: -75
      zoom: 5
      layers: ["http://d3clx83h4jp73a.cloudfront.net/tiles/#{config.cartoTable}/{z}/{x}/{y}.png"]
      cartoLogo: true

    homeScoreboard: new Scoreboard
      el: '[data-page="home"] .scoreboard'

  for el in $('[data-image-flipper]')
    current = $(el).attr 'data-image-flipper'
    new ImageFlipper {el, current}

  devRefs =
    config: require 'zooniverse/config'
    API: require 'zooniverse/API'

  window[name] = reference for name, reference of devRefs if config.dev
