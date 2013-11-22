module FlyerWindow where

import open Flyer
import open Graphics.Location
import Graphics.Collage as Collage
import Window
import Signal
import Mouse

data Event 
 = FPS Time 
 | Click (Int, Int)
 | Display (Int, Int) 

clickEvents : Signal Event
clickEvents = Click <~ Signal.sampleOn Mouse.clicks Mouse.position

tickEvents : Signal Event
tickEvents = FPS <~ fps 32

displayEvent : Signal Event
displayEvent = Display <~ Window.dimensions

allEvents : Signal Event
allEvents = merges [displayEvent, clickEvents, tickEvents]

startFlyer : Flyer
startFlyer = { location = loc (0, 0), orientation = 0 }

scene state =
  let background = 
        Collage.filled black <| 
        Collage.rect state.displayWidth state.displayHeight
      flyer = drawFlyer state.flyer
  in
  Collage.collage (round state.displayWidth) (round state.displayHeight)
                  [background, flyer]

initialState = { flyer = startFlyer
               , animation = Nothing
               , time = 0
               , displayWidth = 400
               , displayHeight = 400
               }

runEvent event state =
  case event of
    FPS frames -> handleState {state| time <- state.time + frames }
    Click coord -> if state.time > 0 then handleClick (toLoc state coord) state
                      else state
    Display (width, height) -> {state| displayWidth <- width, displayHeight <- height}

toLoc state (left, top) =    
  let left' = toFloat <| left - (state.displayWidth `div` 2)
      top' = toFloat <| (state.displayHeight `div` 2) - top
  in loc (left', top')

handleState state = 
  case state.animation of
    Nothing -> state
    Just anim -> 
      let animation' =
            if state.time > anim.finished then Nothing else Just anim
      in {state| flyer <- anim.animation state.time, animation <- animation'}


handleClick location state = 
  let record = flyerRecord location state.flyer state.time
  in {state| animation <- Just record}

main = scene <~ (foldp runEvent initialState allEvents)