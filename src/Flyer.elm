module Flyer where

import open Graphics.Animation
import open Graphics.Location
import open Graphics.Path
import Graphics.Collage as Collage

type Flyer 
 = { location    : Location
   , orientation : Float }
               
moveLoc : Location -> Form -> Form   
moveLoc loc = Collage.move (loc.left, loc.top)   
   
flyerForm : Form
flyerForm = group 
            [Collage.filled red <| Collage.ngon 3 20,
             Collage.move (5, 0) . Collage.filled blue <| Collage.ngon 3 10]

drawFlyer : Flyer -> Form
drawFlyer flyer = 
  Collage.rotate (degrees (flyer.orientation + 90)) . 
  moveLoc flyer.location <| flyerForm  

findAngle location flyer =
  let dx = location.left - flyer.location.left
      dy = location.top - flyer.location.top
      desiredOrientation = -((atan2 dx dy) * 180/pi)
      diff = 
        let diff = desiredOrientation - flyer.orientation in
        if diff > 180 then diff - 360
        else if diff < -180 then diff + 360 else diff
  in if dy == 0 then 0 else diff

findTranslation location flyer =
  let diffX = location.left - flyer.location.left
      diffY = location.top - flyer.location.top
      length = distance flyer.location location
  in ((diffX, diffY), length)

flyerRecord location flyer startTime =
  let       
      (translation, length) = findTranslation location flyer
      movement = ease sineInOut <|
                 move translation <| 
                 5*millisecond*length
                 
      angle = findAngle location flyer
      
      rotation = ease sineOut <| 
                 rotate angle <| 
                 (3*millisecond*(abs angle))
      
      timeline = rotation >> movement 
      animation = timeline.build startTime flyer
      finished = startTime + timeline.duration
  in {animation = animation, finished = finished}

               
rotate : Float -> Time -> Builder Flyer
rotate degrees duration =
  let animation percentage flyer =
        let orientation = flyer.orientation + degrees*percentage
        in { flyer | orientation <- orientation }
  in builder animation duration

move : (Float, Float) -> Time -> Builder Flyer
move (x, y) duration =
  let animation percentage flyer =
        let newX = flyer.location.left + x*percentage
            newY = flyer.location.top + y*percentage
            location = loc (newX, newY)
        in { flyer | location <- location }
  in builder animation duration
