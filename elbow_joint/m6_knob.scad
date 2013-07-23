// inspired by http://www.thingiverse.com/thing:11405

module m6_knob(r, h, $fn=50) {

    o=.1;

    m6_thick = 5.2;

    module plug(r=6, h=2) {
        cylinder(r=r, h=h);
    }

    module knob() {
        difference() {
            hull() {
                cylinder(r=r * 2/3, h=h);
                translate([0,0,h/3]) cylinder(r=r, h=h * 2/3);
            }
            // hex nut hole
            translate([0,0,h - 2 - m6_thick+o]) cylinder(r=5,h=m6_thick+o,$fn=6);
            // pivot screw hole
            translate([0,0,-o]) cylinder(r=3, h=h+2*o);
            // Plug
            translate([0,0,h-2+o]) plug(h=2+o);
            // Grippy bits
            for (angle = [1 : 45 : 359]) {
                assign (radius = r + 1.25)
                    assign (x = radius * cos(angle), y = radius * sin(angle))
                        translate([x, y, 0]) cylinder(r=2.75, h=20);
            }
        }
    }

    knob();
    translate([0,r*2,0]) plug(r=5.5);
}

m6_knob(19/2, 19/2);
