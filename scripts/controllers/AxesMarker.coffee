Spine = require 'Spine'
Raphael = require 'Raphael'

Marker = require 'controllers/Marker'
{indexOf} = require 'util'
style = require 'style'

class AxesMarker extends Marker
	crossCircle: null
	circles: null
	lines: null
	boundingBox: null

	constructor: ->
		super

		@crossCircle = @paper.circle()
		@crossCircle.attr style.crossCircle

		@crossCircle.hover @showBoundingBox, @hideBoundingBox
		@crossCircle.drag @crossDrag, @dragStart, @dragEnd

		points = @marking.points().all()

		@circles = @paper.set(@paper.circle() for p in points)
		@circles.toBack()
		@circles.attr style.circle

		@setupCircleHover()
		@circles.drag @circleDrag, @dragStart

		@lines = @paper.set(@paper.path() for p in points)
		@lines.toBack()
		@lines.attr style.line

		@boundingBox = @paper.path()
		@boundingBox.toBack()
		@boundingBox.attr style.boundingBox

		@marking.trigger 'change'

	setupCircleHover: =>
		marker = @

		over = ->
			marker.overCircle = @
			@attr style.circle_hover

		out = ->
			@attr style.circle

		# These run in the context of the circle!
		@circles.hover over, out

	render: =>
		intersection = @getIntersection()
		@crossCircle.attr cx: intersection.x, cy: intersection.y
		@crossCircle.attr style[@marking.species] or style.crossCircle

		points = @marking.points().all()
		for circle, i in @circles
			circle.attr cx: points[i].x, cy: points[i].y

		for line, i in @lines
			line.attr path: @lineBetween @circles[i], @crossCircle

		@boundingBox.attr path: @getBoundingPathString()

	getIntersection: =>
		points = @marking.points().all()

		grad1 = (points[0].y - points[1].y) / (points[0].x - points[1].x)
		grad2 = (points[2].y - points[3].y) / (points[2].x - points[3].x)

		interX = ((points[2].y - points[0].y) + (grad1 * points[0].x - grad2 * points[2].x)) / (grad1 - grad2)
		interY = grad1 * (interX - points[0].x) + points[0].y

		x: interX, y: interY

	getBoundingPathString: =>
		points = @marking.points().all()
		path = []
		path.push 'M', points[0].x, points[0].y

		# Draw a line to the even points, then the odd points.
		# This draws a nice star around five consecutive points and a box around crossed points.
		for point in points by 2 then path.push 'L', point.x, point.y
		for point in points[1..] by 2 then path.push 'L', point.x, point.y

		path.push 'z'
		path.join ' '

	select: =>
		super

		points = @marking.points().all()
		for circle, i in @circles
			circle.animate
				cx: points[i].x
				cy: points[i].y
				opacity: 1
				200

		@lines.animate opacity: 1, 333
		@boundingBox.animate opacity: 1, 250

	deselect: =>
		super

		@circles.animate
			cx: @crossCircle.attr 'cx'
			cy: @crossCircle.attr 'cy'
			opacity: 0
			250

		@lines.animate opacity: 0, 125
		@boundingBox.animate opacity: 0, 250

	crossDrag: (dx, dy) =>
		@moved = true

		for point, i in @marking.points().all()
			point.updateAttribute 'x', @startPoints[i].x + dx
			point.updateAttribute 'y', @startPoints[i].y + dy

		@marking.trigger 'change'

	circleDrag: (dx, dy) =>
		@moved = true

		points = @marking.points().all()

		i = indexOf @circles, @overCircle
		points[i].updateAttribute 'x', @startPoints[i].x + dx
		points[i].updateAttribute 'y', @startPoints[i].y + dy

		@marking.trigger 'change'

	destroy: =>
		super
		@crossCircle.remove()
		@circles.remove()
		@lines.remove()
		@boundingBox.remove()

exports = AxesMarker