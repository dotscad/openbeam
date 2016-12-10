#!/usr/bin/env python
"""
Script to generate Kossel Pro definition JSON file for Cura

Based on: https://gist.github.com/onitake/78a35293501b03c2dd72c9ab5dede1db
See also: https://ultimaker.com/en/community/21355-am-i-wrong-or-this-new-cura-212-doesnt-support-delta-printers?page=last
"""

import sys
import math
import json

# Build the machine_disallowed_areas to the requested precision
steps = 6
radius = 125.0  # slightly larger because Cura adds padding
precision = 3
anglestep = math.pi / 2 / steps
points = []
for step in xrange(steps + 1):
    angle = anglestep * step
    points.append([ round(math.cos(angle) * radius, precision), round(math.sin(angle) * radius, precision)])

polys = []
for step in xrange(steps):
    polys.append([
        [ radius, radius ],
        [ points[step][0], points[step][1] ],
        [ points[step + 1][0], points[step + 1][1] ],
    ])
    polys.append([
        [ -radius, radius ],
        [ -points[step][0], points[step][1] ],
        [ -points[step + 1][0], points[step + 1][1] ],
    ])
    polys.append([
        [ radius, -radius ],
        [ points[step][0], -points[step][1] ],
        [ points[step + 1][0], -points[step + 1][1] ],
    ])
    polys.append([
        [ -radius, -radius ],
        [ -points[step][0], -points[step][1] ],
        [ -points[step + 1][0], -points[step + 1][1] ],
    ])

# In case you want to see it in OpenSCAD
# for poly in polys:
#     print 'polygon(points=[[{},{}],[{},{}],[{},{}]]);'.format(poly[0][0],poly[0][1],poly[1][0],poly[1][1],poly[2][0],poly[2][1])

start_gcode = """; info: M303 E0 S200 C8 ; Pid auto-tune 

M140 S{{material_bed_temperature}}; Start heating up the base
G28 ; Home to top 3 endstops
; Autolevel and adjust first layer
G29 Z0.25 ; Adjust this value to fit your own printer! (positive is thicker)

; Squirt and wipe ;
M109 S220 ; Wait for the temp to hit 220
G00 X125 Y-60 Z0.1 ;
G92 E0 ;
G01 E25 F100 ; Extrude a little bit to replace oozage from auto levelling
G01 X90 Y-50 F6000 ;
G01 Z5 ;

; Set the extruder to the requested print temperature
M104 S{{material_print_temperature}}
"""

end_gcode = """M104 S0 ; turn off temperature
M140 S0 ; turn off bed
G28 ; home all axes
M84 ; disable motors
"""

definition = """{{
    "id": "kossel_pro",
    "version": 2,
    "name": "Kossel Pro",
    "inherits": "fdmprinter",
    "metadata": {{
        "visible": true,
        "author": "Chris Petersen",
        "manufacturer": "OpenBeam",
        "category": "Other",
        "file_formats": "text/x-gcode",
        "icon": "icon_ultimaker2",
        "platform": "kossel_pro_build_platform.stl"
    }},
    "overrides": {{
        "machine_heated_bed": {{
            "default_value": true
        }},
        "machine_width": {{
            "default_value": 240
        }},
        "machine_height": {{
            "default_value": 240
        }},
        "machine_depth": {{
            "default_value": 240
        }},
        "machine_center_is_zero": {{
            "default_value": true
        }},
        "machine_nozzle_size": {{
            "default_value": 0.35
        }},
        "material_diameter": {{
            "default_value": 1.75
        }},
        "machine_nozzle_heat_up_speed": {{
            "default_value": 2
        }},
        "machine_nozzle_cool_down_speed": {{
            "default_value": 2
        }},
        "machine_gcode_flavor": {{
            "default_value": "RepRap (Marlin/Sprinter)"
        }},
        "machine_start_gcode": {{
            "default_value": {start_gcode}
        }},
        "machine_end_gcode": {{
            "default_value": {end_gcode}
        }},
        "machine_disallowed_areas": {{
            "default_value": {polys}
        }}
    }}
}}""".format(start_gcode=json.dumps(start_gcode),end_gcode=json.dumps(end_gcode),polys=json.dumps(polys))


with open('kossel_pro.def.json', 'wb') as f:
    f.write(definition)
