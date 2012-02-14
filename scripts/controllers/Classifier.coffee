define (require) ->
	Spine = require 'Spine'
	$ = require 'jQuery'

	class Classifier extends Spine.Controller
		subject: null
		picker: null

		elements:
			'.position > .latitude': 'latitude'
			'.position > .longitude': 'longitude'
			'.depth > .meters': 'depth'
			'.steps': 'steps'
			'.ground-cover.step': 'groundCoverStep'
			'.ground-cover.toggles button': 'groundCoverButtons'
			'.ground-cover .finished': 'groundCoverFinishedButton'
			'.species.step': 'speciesStep'
			'.species.toggles button': 'speciesButtons'
			'.species .finished': 'speciesFinishedButton'
			'.summary .total': 'total'

		events:
			'click .ground-cover.toggles button': 'groundCoverChanged'
			'click .ground-cover .finished': 'finishedGroundCover'
			'click .species.toggles button': 'speciesChanged'
			'click .species > .finished': 'finishedSpecies'
			'click .next': 'reset'

		constructor: ->
			super

			@picker.bind 'selected', @selectionChanged

			if @subject then @setSubject @subject

		setSubject: (@subject) =>
			@reset()

			@picker.setImgSrc @subject.src
			@latitude.html @subject.latitude
			@longitude.html @subject.longitude
			@depth.html @subject.depth

		selectionChanged: (marking) =>
			@speciesButtons.each ->
				button = $(@)

				if button.val() is marking?.type
					button.addClass 'active'
				else
					button.removeClass 'active'

			@updateActiveSpeciesToggle()

		groundCoverChanged: (e) =>
			@log 'Ground cover changed', e.target.value
			@subject.updateAttribute 'groundCover', e.target.value

			@groundCoverButtons.removeClass 'active'
			$(e.target).addClass 'active'

			@groundCoverFinishedButton.attr 'disabled', false

		finishedGroundCover: =>
			@log 'Finished ground cover'
			@groundCoverStep.addClass 'finished'
			@groundCoverStep.removeClass 'active'
			@speciesStep.addClass 'active'
			@picker.setDisabled false

		speciesChanged: (e) =>
			target = $(e.target)
			for marking in @picker.markings when marking.active
				marking.setType target.val()

			@updateSpeciesCounts()
			@updateActiveSpeciesToggle()

			@total.html @picker.markings.length

		updateSpeciesCounts: =>
			@speciesButtons.find('.count').html '0'

			toggled = false

			for marking in @picker.markings when marking.type
				button = @speciesButtons.filter "[value='#{marking.type}']"
				countContainer = button.find '.count'
				countContainer.html parseInt(countContainer.html(), 10) + 1

		updateActiveSpeciesToggle: =>
			activeMarkings = (marking for marking in @picker.markings when marking.active)
			if activeMarkings.length isnt 0
				activeType = activeMarkings[0].type
			else
				activeType = ''

			@log 'Activating toggle for', activeType

			@speciesButtons.each ->
				button = $(@)

				if button.val() is activeType
					button.addClass 'active'
				else
					button.removeClass 'active'

		finishedSpecies: =>
			@picker.setDisabled true

			species = {}
			for marking in @picker.markings
				species[marking.type] ||= []
				species[marking.type].push marking.points

			@subject.updateAttribute 'species', species

			@steps.addClass 'finished'

		reset: =>
			@picker.reset()
			@picker.setDisabled true

			@steps.removeClass 'finished'

			@groundCoverStep.removeClass 'finished'
			@groundCoverStep.addClass 'active'
			@groundCoverButtons.each -> $(@).removeClass 'active'

			@speciesStep.removeClass 'active'
			@speciesButtons.each -> $(@).removeClass 'active'
