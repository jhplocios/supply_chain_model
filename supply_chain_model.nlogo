; Initialize globals
globals[
  roads
  first-ex-patches
  second-ex-patches
  extractor-pick-ups
  manufacturer-drop-offs
  hospital-drop-offs
  intersections
]

; Initialize the breeds
breed [extractors extractor]
breed [manufacturers factory]
breed [hospitals hospital]
breed [patients patient]
breed [extr-transporters ex-truck]
breed [hosp-transporters hs-truck]

; Initialize internal values per breed
extr-transporters-own[
  load_capacity
  delivery_speed
  current_load
  heading_towards
  start_patch
  destination
]
hosp-transporters-own[
  load_capacity
  delivery_speed
  current_load
  start_patch
  destination
]
extractors-own[
  extractor_capacity
  extraction_rate
  raw_material_1_count
  raw_material_1_type

  raw_material_2_count
  raw_material_2_type

  raw_material_3_count
  raw_material_3_type

  raw_material_4_count
  raw_material_4_type
]
manufacturers-own[
  warehouse_capacity
  manufacturing_rate
  current_inven
]
hospitals-own[
  patient_capacity
  patient_count

  glove_stock
  ppe_stock
  mask_stock
  syringe_stock

  glove_capacity
  ppe_capacity
  mask_capacity
  syringe_capacity
]
patients-own[
  health
  start_patch
  destination
]

; Intialize environment
to setup

  clear-all
  reset-ticks

  setup-patches
  setup-agents
  setup-positions

end

; Setup roads and patches
to setup-patches

    ask patches [
    set pcolor green + 3
    ]

  ;; initialize the global variables that hold patch agentsets
  set roads patches with [
    ; left vertical road
    (pxcor = -10 and pycor < 4 and pycor > -14) or
    ; right vertical road
    (pxcor = 10 and pycor < 4 and pycor > -14) or
    ; top horizontal road
    (pycor = 3) or
    ; bottom horizontal road
    (pycor = -13)
  ]

  set intersections roads with [
    (pxcor = -10 and pycor = 3) or
    (pxcor = -10 and pycor = -13) or
    (pxcor = 10 and pycor = 3) or
    (pxcor = 10 and pycor = -13)
  ]

  ; Set patches to be traveled by the upper extractor
  set first-ex-patches patches with [
    (pxcor >= -30 and pxcor < -10) and
    pycor > 3
  ]

  ; Set patches to be traveled by the lower  extractor
  set second-ex-patches patches with [
    (pxcor >= -30 and pxcor < -10) and
    (pycor > -13 and pycor < 3)
  ]

  ; Set patches to be the pickup point
  set extractor-pick-ups patches with [

    (pycor = 3 or pycor = -13) and
   (pxcor > -23 and pxcor < -19)

  ]

  ; Set patches to be the drop off point from extractor to manufacturers
  set manufacturer-drop-offs patches with [

    (pycor = 3 or pycor = -13) and
   (pxcor > -1 and pxcor < 3)

  ]

  ; Set patches to be the drop off point from manufacturers to hospitals
  set hospital-drop-offs patches with [

    (pycor = 3 or pycor = -13) and
   (pxcor > 18 and pxcor < 22)

  ]

  ; Set colors of patches
  ask first-ex-patches [ set pcolor grey + 2]
  ask second-ex-patches [ set pcolor grey + 2]
  ask roads [ set pcolor white ]
  ask extractor-pick-ups [set pcolor yellow + 2]
  ask manufacturer-drop-offs [set pcolor brown + 2]
  ask hospital-drop-offs [set pcolor red + 2]

end

; Create agents with specific designs
to setup-agents

  ; Sets the default shape for every agents so that spawning is easy
  set-default-shape extractors "bulldozer top"
  set-default-shape manufacturers "factory"
  set-default-shape hospitals "hospital"
  set-default-shape patients "dot"
  set-default-shape extr-transporters "truck"
  set-default-shape hosp-transporters "truck"

  ; Create agents with hard-coded number for non-transporters
  create-extractors 2[
    set size 5
    set color yellow
    set heading 0
    set extractor_capacity extractor-capacity
  ]
  create-manufacturers 2[
    set size 12
    set color brown
    set warehouse_capacity manufacturer-capacity
  ]
  create-hospitals 2 [
    set size 12
    set color gray
    set patient_count 0
    set patient_capacity patient-capacity
    set glove_capacity glove-capacity
    set ppe_capacity ppe-capacity
    set mask_capacity mask-capacity
    set syringe_capacity syringe-capacity
  ]

   create-patients 100 [
    set size 1
    set color orange
    set health initial-health
  ]

  create-extr-transporters (transporter_multiplier * 2)[
    set size  2
    set color red
    set load_capacity load-capacity
  ]

  create-hosp-transporters (transporter_multiplier * 2)[
    set size  2
    set color blue
    set load_capacity load-capacity
  ]


end

; Places each non-moving breed in the grid
to setup-positions

  ; Hospitals
  let n 9
  foreach sort hospitals [ h ->
   ask h [
      setxy 20 n
      set n (n - 16)
      display
    ]
  ]

  ; Manufacturers
  set n 8.3
  foreach sort manufacturers [ m ->
   ask m [
      setxy 0 n
      set n (n - 16)
      display
    ]
  ]

  ; Extractors

  ask extractor 0 [
    move-to one-of first-ex-patches
  ]
  ask extractor 1 [
    move-to one-of second-ex-patches
  ]

  ; Transporters heading to extractors
  set n 0
  foreach sort extr-transporters [ tr ->
   ask tr [

      (ifelse
        n mod 2 = 0 [
          set start_patch patch 1 3
          setxy 1 3
        ][
          set start_patch patch 1 -13
          setxy 1 -13
        ]
      )

      ; Set random heading
      ifelse coin-flip?
      [
        set destination patch -21 3
      ]
      [
        set destination patch -21 -13
      ]

      set heading 270
      display
      set n (n + 1)

    ]
  ]

  ; Transporters heading to hospitals
  set n 0
  foreach sort hosp-transporters [ tr ->
   ask tr [

      (ifelse
        n mod 2 = 0 [
          set start_patch patch 1 3
          setxy 1 3
        ][
          set start_patch patch 1 -13
          setxy 1 -13
        ]
      )

      ; Set random heading
      ifelse coin-flip?
      [
        set destination patch 21 3
      ]
      [
        set destination patch 21 -13
      ]

      set heading 90
      display
      set n (n + 1)

    ]
  ]

  foreach sort patients [ tr ->
   ask tr [


      ifelse coin-flip?
      [
        setxy 30 3
        ; set heading towards turtle 4
        set destination patch 20 3
      ]
      [
        setxy 30 -13
        ; set heading towards turtle 5
        set destination patch 20 -13
      ]

      set heading -90
      display
    ]
  ]
end

; Patients to move
to patient-move foreach sort patients [p ->

  ask p [

    ifelse (patch-here = destination) [

        let hosp_number 0
        ifelse [pycor] of patch-here = 3
        [
          set hosp_number 4
        ]
        [
          set hosp_number 5
        ]

        ; increment patient count in the hospital if the patient is already in the hospital
        ask hospital hosp_number
        [
          ; if there is a slot in the current hospital, admit self
          ifelse ((patient_count + 1) <= patient_capacity)
          [
            set patient_count (patient_count + 1)
            ask p
            [
              set color green
            ]
          ]
          [
            ; else reroute the patient to another hospital
            ask p
            [
              ; only reroute the unhealthy patients
              if(color != green)
              [
                ifelse (one-of hospitals with [patient_count < patient_capacity] = nobody)[
                  set health (health - 1)
                  death
                ]
                [
                  set destination [patch xcor ycor] of one-of hospitals with [patient_count < patient_capacity]
                  set heading towards one-of hospitals-on destination
                  forward 1
                ]
              ]
            ]
          ]

          ; else lipat hospital
        ]

      ; coin-flip if the patient will get healthy or not
      if coin-flip?
      [
        ; not green = not healthy
        if (color != green)
        [
          set health (health - 1)
          death
        ]

      ]
    ]
    [
      forward 1
    ]

  ]
]
end

; Discharge if a patient is in the hospital
to discharge-patients foreach sort patients [p ->
  ask p [

    if (patch-here = destination) [

      let hosp_number 0
        ifelse [pycor] of patch-here = 3
        [
          set hosp_number 4
        ]
        [
          set hosp_number 5
        ]
        ask p
        [
          set health health + 1
          if (health >= 90)
          [
            ask hospital hosp_number
            [
              set patient_count (patient_count - 1)
            ]
          ]

        ]

       if (color = green)
        [

          ; hide
        ]
    ]
  ]
]
end

; Admit a patient in the hospital if outside
to admit-patient
  if patient_count < patient_capacity
  [
    set patient_count patient_count + 1
    ; how to stop patients from moving if ever while "getting treated" (?)
  ]
end

; Creates a patient in near the hospitals
to spawn-patient
    create-patients 1 [
    set size 1
    set color orange
    ifelse coin-flip?
    [
      setxy 30 3
      set destination patch 20 3
    ]
    [
      setxy 30 -13
      set destination patch 20 -13
    ]
    set health initial-health
    set heading -90
    ; set destination [patch xcor ycor] of one-of hospitals
    ; set heading towards one-of hospitals-on destination
  ]
end

; Get the patch of a turtle
to-report get-patch [turt]

  let dest 0
  ask turt [
    set dest (patch-here)
  ]
  report dest
end

; Get the x coordinate of a turtle
to-report get-coords-x [turt]

  let x 0
  ask turt [
   set x (xcor)
  ]

  report x
end

; Get the y coordinate of a turtle
to-report get-coords-y [turt]

  let y 0
  ask turt [
   set y (ycor)
  ]

  report y
end

; Randomize choice
to-report coin-flip?
  report random 2 = 0
end

; Allows the extractor transporters to change lanes
to rotate-ext-transporters ; ext-transpoter procedure

  let x_start [pxcor] of start_patch
  let y_start [pycor] of start_patch
  let x_dest  [pxcor] of destination
  let y_dest  [pycor] of destination
  let x_cur   [pxcor] of patch-here
  let y_cur   [pycor] of patch-here

    ; 3 or -13
    if
    (
      ; Check if the current patch is an intersection
      (member? patch-here intersections) and
      (y_start != y_dest)
    )
    [
      ;; COORDINATES GUIDE;;
      ; 2 is the x coordinate of the manufacturers
      ; -21 is the x coordinate of the extractors pickup point
      ; 3 is the y coordinate of the upper lane
      ; -13 is the y coordinate of the lower lane

      (
      ifelse
      ; If the the transporter is a horizontal road
      ( y_dest != y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt 90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
        )
      ]
      ; If the transporter is in a vertical road
      (y_dest = y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt 90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
        )
      ]
      )

    ]

end

; Allows the hospital transporters to change lanes
to rotate-hosp-transporters ;  hosp-transporter procedure

  let x_start [pxcor] of start_patch
  let y_start [pycor] of start_patch
  let x_dest  [pxcor] of destination
  let y_dest  [pycor] of destination
  let x_cur   [pxcor] of patch-here
  let y_cur   [pycor] of patch-here

    ; 3 or -13
    if
    (
      ; Check if the current patch is an intersection
      (member? patch-here intersections) and
      (y_start != y_dest)
    )
    [
      ;; COORDINATES GUIDE;;
      ; 2 is the x coordinate of the manufacturers
      ; -21 is the x coordinate of the extractors pickup point
      ; 3 is the y coordinate of the upper lane
      ; -13 is the y coordinate of the lower lane

      (
      ifelse
      ; If the the transporter is a horizontal road
      ( y_dest != y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt -90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
        )
      ]
      ; If the transporter is in a vertical road
      (y_dest = y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt -90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
        )
      ]
      )

    ]

end

; Allows the transporters to move
to transport ; transporter procedure

  ; Transports the raw materials to the manufacturer
  ask extr-transporters[
    let temp_dest 0

    ; If the tranporter reached its destination
    if (patch-here = destination) [

      set temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)

      ; Check if y-coordinate is 3 (upper extractor)
      ; or -13 (lower extractor)
      if (member? patch-here extractor-pick-ups)
      [
        let extractor_number 0
        ifelse [pycor] of patch-here = 3
        [
          set extractor_number 0
        ]
        [
          set extractor_number 1
        ]

        ask extractor extractor_number [
          ; Get the raw materials from the extractors
          set raw_material_1_count (raw_material_1_count - 1)
          set raw_material_2_count (raw_material_2_count - 1)
          set raw_material_3_count (raw_material_3_count - 1)
          set raw_material_4_count (raw_material_4_count - 1)
        ]

      ]

      ; Check if y-coordinate is 3 (upper manufacturer)
      ; or -13 (lower manufacturer)
      if (member? patch-here manufacturer-drop-offs)
      [
        let manuf_number 0
        ifelse [pycor] of patch-here = 3
        [
          set manuf_number 2
        ]
        [
          set manuf_number 3
        ]

        ask factory manuf_number [
           ; Add current inventory to the manufacturer destination
           set current_inven (current_inven + 1)
        ]

      ]

      ; Rotate to go back
      rt 180

    ]

    ; Rotate if in an intersection
    rotate-ext-transporters

    forward 1
    display
  ]

  ; Transports the manufactured goods to the hospitals
  ask hosp-transporters[
    let temp_dest 0
    if (patch-here = destination) [

      set temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)

      ; Check if y-coordinate is 3 (upper hospital)
      ; or -13 (lower hospital)
      if (member? patch-here hospital-drop-offs)
      [
        let hosp_number 0
        ifelse [pycor] of patch-here = 3
        [
          set hosp_number 4
        ]
        [
          set hosp_number 5
        ]

        ask hospital hosp_number [
          ; Add stock to the hospital destination
          set glove_stock (glove_stock + 1)
          set ppe_stock (ppe_stock + 1)
          set mask_stock (mask_stock + 1)
          set syringe_stock (syringe_stock + 1)
        ]

      ]

      ; Check if y-coordinate is 3 (upper manufacturer)
      ; or -13 (lower manufacturer)
      if (member? patch-here manufacturer-drop-offs)
      [
        let manuf_number 0
        ifelse [pycor] of patch-here = 3
        [
          set manuf_number 2
        ]
        [
          set manuf_number 3
        ]

        ask factory manuf_number [
           ; Add current inventory to the manufacturer destination
           set current_inven (current_inven - 1)
        ]

      ]


      rt 180

    ]

    rotate-hosp-transporters
    forward 1
    display
  ]

end

; Allows the extractors to extract
to extract ; extractor procedure

  ask extractors
  [
    if patch-ahead 1 = nobody or [pcolor] of patch-ahead 1 != grey + 2
    [
      rt 180
    ]

    if ticks mod 10 = 0
    [
      rt random 40
      lt random 40
      fd 0.5
    ]
  ]

end

; function to kill a patient if health reaches 0
to death
  if health < 0 [die]
end

; Function at each time step (tick)
to go
  transport
  extract
  patient-move
  spawn-patient
  discharge-patients
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
534
16
1325
474
-1
-1
12.85
1
10
1
1
1
0
0
0
1
-30
30
-17
17
0
0
1
ticks
30.0

BUTTON
371
445
435
478
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
454
445
517
478
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
32
217
65
transporter_multiplier
transporter_multiplier
1
10
7.0
1
1
NIL
HORIZONTAL

TEXTBOX
117
15
218
33
will be multiplied to 2
11
0.0
1

SLIDER
10
102
231
135
extractor-capacity
extractor-capacity
10
100
34.0
1
1
items
HORIZONTAL

SLIDER
813
525
1023
558
extraction-rate
extraction-rate
10
100
50.0
1
1
items per tick
HORIZONTAL

TEXTBOX
15
81
165
99
Extractor variables
11
0.0
1

SLIDER
279
109
499
142
manufacturer-capacity
manufacturer-capacity
10
100
76.0
1
1
items
HORIZONTAL

SLIDER
812
565
1025
598
manufacture-rate
manufacture-rate
10
100
50.0
1
1
items per tick
HORIZONTAL

TEXTBOX
288
90
438
108
Manufacturer variables
11
0.0
1

SLIDER
11
162
233
195
patient-capacity
patient-capacity
10
100
100.0
1
1
patients
HORIZONTAL

SLIDER
1050
527
1273
560
admission-rate
admission-rate
10
100
50.0
1
1
patients per tick
HORIZONTAL

SLIDER
1051
564
1274
597
release-rate
release-rate
0
100
50.0
1
1
patients per tick
HORIZONTAL

SLIDER
10
297
233
330
ppe-capacity
ppe-capacity
0
100
33.0
1
1
PPEs
HORIZONTAL

SLIDER
8
206
230
239
mask-capacity
mask-capacity
0
100
49.0
1
1
masks
HORIZONTAL

SLIDER
9
344
233
377
glove-capacity
glove-capacity
0
100
31.0
1
1
gloves
HORIZONTAL

SLIDER
7
250
230
283
syringe-capacity
syringe-capacity
0
100
35.0
1
1
syringes
HORIZONTAL

TEXTBOX
16
144
166
162
Hospital variables
11
0.0
1

TEXTBOX
285
156
435
174
Transporter variables
11
0.0
1

SLIDER
281
172
501
205
load-capacity
load-capacity
0
100
35.0
1
1
items
HORIZONTAL

TEXTBOX
808
503
958
521
Just for later (if ever)
11
15.0
1

TEXTBOX
286
214
436
232
Patient variables
11
0.0
1

SLIDER
281
231
507
264
initial-health
initial-health
0
100
47.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bulldozer top
true
0
Rectangle -7500403 true true 195 60 255 255
Rectangle -16777216 false false 195 60 255 255
Rectangle -7500403 true true 45 60 105 255
Rectangle -16777216 false false 45 60 105 255
Line -16777216 false 45 75 255 75
Line -16777216 false 45 105 255 105
Line -16777216 false 45 60 255 60
Line -16777216 false 45 240 255 240
Line -16777216 false 45 225 255 225
Line -16777216 false 45 195 255 195
Line -16777216 false 45 150 255 150
Polygon -1184463 true true 90 60 75 90 75 240 120 255 180 255 225 240 225 90 210 60
Polygon -16777216 false false 225 90 210 60 211 246 225 240
Polygon -16777216 false false 75 90 90 60 89 246 75 240
Polygon -16777216 false false 89 247 116 254 183 255 211 246 211 211 90 210
Rectangle -16777216 false false 90 60 210 90
Rectangle -1184463 true true 180 30 195 90
Rectangle -16777216 false false 105 30 120 90
Rectangle -1184463 true true 105 45 120 90
Rectangle -16777216 false false 180 45 195 90
Polygon -16777216 true false 195 105 180 120 120 120 105 105
Polygon -16777216 true false 105 199 120 188 180 188 195 199
Polygon -16777216 true false 195 120 180 135 180 180 195 195
Polygon -16777216 true false 105 120 120 135 120 180 105 195
Line -1184463 true 105 165 195 165
Circle -16777216 true false 113 226 14
Polygon -1184463 true true 105 15 60 30 60 45 240 45 240 30 195 15
Polygon -16777216 false false 105 15 60 30 60 45 240 45 240 30 195 15

circle
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

hospital
false
0
Rectangle -7500403 true true 90 75 210 285
Polygon -1 true false 210 285 255 255 255 45 210 75
Polygon -13345367 true false 90 75 45 45 45 255 90 285
Polygon -11221820 true false 45 45 90 15 210 15 255 45 210 75 90 75
Rectangle -2674135 true false 135 30 165 120
Rectangle -2674135 true false 105 60 195 90

line
true
0
Line -7500403 true 150 0 150 300

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

truck
true
0
Rectangle -7500403 true true 45 105 187 296
Polygon -7500403 true true 193 4 150 4 134 41 104 56 104 92 194 93
Rectangle -1 true false 60 105 105 105
Polygon -16777216 true false 112 62 141 48 141 81 112 82
Circle -16777216 true false 174 24 42
Rectangle -7500403 true true 185 86 194 119
Circle -16777216 true false 174 114 42
Circle -16777216 true false 174 234 42
Circle -7500403 false true 174 234 42
Circle -7500403 false true 174 114 42
Circle -7500403 false true 174 24 42
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
