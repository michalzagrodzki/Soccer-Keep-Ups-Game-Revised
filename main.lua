-- DISCLAIMER All sections are intendated - for rolling up parts of code

-- Initial properties

	--> Hide status bar
	display.setStatusBar( display.HiddenStatusBar )

	--> Physics engine
	local physics = require( "physics" )
	physics.start( )

-- [[ Code scheme follows >> Classes Pattern <<
	
	-- Neccessary Classes

	-- Variables and Constraints

	-- Declaring Functions
		-- Constructor (Main Function)
		-- Class Methods (Other Functions)

	-- Call Main Function to start program

--]]

-- Graphics

-- >> Title Screen <<
	
	local titleView
	local titleBackground
	local playButton
	local creditsButton
	
-- >> Credits Screen <<

	local creditsView

-- !! Variables

	-- Game Background

		local gameBackground

	-- Instructions

		local instructions

	-- Score Fields (for counting score)
		
		local scoreField

	-- Ball
		
		local ball

	-- Alert (when game is finished)

		local alertView

	-- Sounds

		local hitBall = audio.loadSound( "Footbal_kick.mp3" )

	-- stores the graphics information for floor

		local floor 

-- !! Functions
	
	local Main = {}						--0
	local startButtonListeners = {}		--1
	local showCredits = {}				--2
	local hideCredits = {} 				--3
	local showGameView = {} 			--4
	local gameListeners = {} 			--5
	local onTap = {} 					--6
	local onCollision = {}				--7
	local alert = {}					--8


-- Constructor Main() 					>>> 0 <<<

	-- Main Menu View

	function Main()
		
		titleView 			= display.newGroup( )											-- Grouping everything
		titleBackground 	= display.newImage( titleView, "titleBackground.png" )			-- Background picture
		playButton 			= display.newImage( titleView, "playButton.png", 200, 240 )		-- Button for starting game
		creditsButton 		= display.newImage( titleView, "creditsButton.png", 198, 290 )	-- Button for credits

			titleBackground.x = display.contentCenterX 			-- Properties for titleBackground image - placing it in center of x 
			titleBackground.y = display.contentCenterY 			-- Properties for titleBackground image - placing it in center of y 
	
		startButtonListeners("add")
	end

-- Listeners for titleView group 		>>> 1 <<<
	-- Associates functions to buttons in Main Menu View

	function startButtonListeners(action)
		if(action == "add") then
			playButton:addEventListener( "tap", showGameView )
			creditsButton:addEventListener( "tap", showCredits )
		else
			playButton:removeEventListener( "tap", showGameView )
			creditsButton:removeEventListener( "tap", showCredits )
		end
	end

-- Showing Credits 						>>> 2 <<<

	function showCredits:tap( e )
		playButton.isVisible = false
		creditsButton.isVisible = false
		creditsView = display.newImage( "credits.png", -130, display.contentHeight-140)
		transition.to( creditsView, {time = 300, x = 65, onComplete = function() creditsView:addEventListener( "tap", hideCredits ) end } )
	end

-- Hiding Credits 						>>> 3 <<<

	function hideCredits:tap( e )
		playButton.isVisible = true
		creditsButton.isVisible = true
		transition.to( creditsView, {time = 300, y = display.contentHeight+creditsView.height, onComplete = function() creditsView:removeEventListener( "tap", hideCredits ) display.remove(creditsView) creditsView = nil end } )
	end

-- Showing Game View 					>>> 4 <<<

	-- Makes transition between Title View and Game View
	function showGameView:tap( e )
		transition.to( titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners("rmv") display.remove(titleView) titleView = nil end })


		-- Adding Game Background
		gameBackground = display.newImage( "gameBackground01.png", 54, 14 )
			gameBackground.x = display.contentCenterX
			gameBackground.y = display.contentCenterY

		-- Showing and hiding Instructions
		instructions = display.newImage( "instructions.png", 85, 260 )
		transition.from( instructions, {time = 200, alpha = 0.1, onComplete = function() timer.performWithDelay(2000, function() transition.to( instructions, {time = 200, alpha = 0.1, onComplete = function() display.remove(instructions) instructions = nil end }) end) end})

		-- Score Fields
		scoreField = display.newText( "0", 62, 295, "Marker Felt", 16 )
		scoreField:setTextColor( 255, 204, 0 )

		-- Ball
		ball = display.newImage( "ball.png", 205, 250 )
		ball.name = "ball" 	-- index in table

		-- Floor
			-- used for bottom boundary - detects collision with floor
		floor = display.newLine( 240, 321, 700, 321 )

		-- Adding PHYSICS to objects (ball, floor)

			-- Ball
			physics.addBody( ball, "dynamic", {radius = 30} )

			-- Floor
			physics.addBody( floor, "static" )

		-- Triggers listeners to start game
		gameListeners("add")
	end

-- Listeners for game 					>>> 5 <<<

	-- actions for tapping ball and for collision of ball with floor
	function gameListeners( action )
		if (action == 'add') then
			ball:addEventListener( "tap", onTap )
			floor:addEventListener( "collision", onCollision )
		else
			ball:removeEventListener( "tap", onTap)
			floor:removeEventListener( "collision", onCollision)
		end
	end

-- Kick ball 							>>> 6 <<<

	function onTap ( e )
		-- play sound
		audio.play( hitBall )
		-- kick ball up
		ball:applyForce((ball.x - e.x) * 0.1, -10, ball.x, ball.y)
		-- update score
		scoreField.text = tostring( tonumber( scoreField.text + 1 ) )
	end

-- Collision between ball and floor 	>>> 7 <<<

	function onCollision( e )	
		if (tonumber(scoreField.text) > 1 ) then
			alert(scoreField.text)	
		end
		scoreField.text = 0
	end

-- Alert after finished game 		 	>>> 8 <<<

	function alert( score )
		gameListeners("rmv")
		-- setting up alertView
		alertView = display.newImage( "alert.png", (display.contentWidth * 0.5) - 105, (display.contentHeight * 0.5) - 55 )
		-- making transition from initial state to alertView
		transition.from( alertView, {time = 300, xScale = 0.5, yScale = 0.5 } )
		-- showing score after game
		local score = display.newText( scoreField.text, (display.contentWidth * 0.5) - 8, (display.contentHeight * 0.5), "Marker Felt", 18 )

		-- wait 6 seconds to return to Main Menu
		timer.performWithDelay( 6000, function() Main( ) end, 1 )	
	end

-- Calling main function and starting game

Main()
