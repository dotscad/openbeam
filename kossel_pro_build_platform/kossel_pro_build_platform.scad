/**
 * kossel_pro_build_platform.scad
 *
 * This is a quick hack up of the OpenBeam Kossel Pro build platform that can
 * be used in your favorite slicing app (E.g. Cura, KISSlicer).  Many liberties
 * have been taken with accuracy in favor of appearance with these slicing apps.
 *
 * This borrows heavily from the .scad files created by Johann Rocholl for the
 * original open source Kossel printer, and thus is redistributed under the same
 * GPLv3 license.
 *
 * The original OpenBeam extrusions have been replaced with simpler shape both
 * to save triangles, and because OpenBeam's CC-SA license (requiring
 * attribution) is not compatible with the GPL in this use case.
 *
 * This openSCAD library is part of the [dotscad](https://github.com/dotscad/dotscad)
 * project.
 *
 * @copyright  Chris Petersen, 2016
 * @license    https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 * @see        https://github.com/jcrocholl/kossel
 * @see        http://www.thingiverse.com/thing:100960
 */


extrusion = 15;
width = 360;  // http://ztautomations.dozuki.com/Guide/4%29+Lower+Triangle/9
glass_r = 125;

cntr=tan(30)*(width+22.5)/2;

$o = .1;

use <MCAD/boxes.scad>;

module rbox(size, radius) {
     translate(size/2) roundedBox(size, radius, true, $fn=25);
}

// Simplified vertex module copied liberally from https://github.com/jcrocholl/kossel
module vertex(height, idler_offset, idler_space, $fn=25) {
    roundness = 6;
    difference() {
        union() {
        intersection() {
            translate([0, 22, 0])
                cylinder(r=36, h=height, center=true, $fn=60);
                translate([0, -37, 0]) rotate([0, 0, 30])
                cylinder(r=50, h=height+1, center=true, $fn=6);
            }
            translate([0, 38, 0]) intersection() {
                rotate([0, 0, -90])
                cylinder(r=55, h=height, center=true, $fn=3);
                translate([0, 10, 0])
                cube([100, 100, 2*height], center=true);
                translate([0, -10, 0]) rotate([0, 0, 30])
                cylinder(r=55, h=height+1, center=true, $fn=6);
            }
        }
        difference() {
            translate([0, 58, 0]) minkowski() {
              intersection() {
                rotate([0, 0, -90])
                  cylinder(r=55, h=height, center=true, $fn=3);
                translate([0, -32, 0])
                  cube([100, 16, 2*height], center=true);
              }
              cylinder(r=roundness, h=1, center=true);
            }
            // Idler support cones.
            translate([0, 26+idler_offset-30, 0]) rotate([-90, 0, 0])
              cylinder(r1=30, r2=2, h=30-idler_space/2);
            translate([0, 26+idler_offset+30, 0]) rotate([90, 0, 0])
              cylinder(r1=30, r2=2, h=30-idler_space/2);
        }
        translate([0, 58, 0]) minkowski() {
            intersection() {
              rotate([0, 0, -90])
                cylinder(r=55, h=height, center=true, $fn=3);
              translate([0, 7, 0])
                cube([100, 30, 2*height], center=true);
            }
            cylinder(r=roundness, h=1, center=true);
        }
    }
}

module beam(h) {
    slot = 4;
    linear_extrude(height=h, center = false, convexity = 10)
        // OpenBeam CC-SA license conflicts with Kossel and Cura's GPL, so can't actually use this:
        //import(file="TL-400-0101-002.DXF");
        difference() {
            translate([-extrusion/2,-extrusion/2]) square([extrusion,extrusion]);
            translate([-slot/2,extrusion/2-slot]) square([slot,slot+1]);
            translate([-slot/2,-extrusion/2-1]) square([slot,slot+1]);
            translate([extrusion/2-slot,-slot/2]) square([slot+1,slot]);
            translate([-extrusion/2-1,-slot/2]) square([slot+1,slot]);
        }
}

module frame(txt="") {
    union() {
        beam(50);
        translate([0, 0, 22.5])   difference() {
            // No idler cones.
            vertex(3*extrusion, idler_offset=0, idler_space=100);
            // KOSSEL logotype.
            translate([0, -10, 0]) rotate([90, 0, 0])
              linear_extrude(height=5) text(txt, size=20, valign="center", halign="center");
        }
    }
}

module side(txt) {
    union() {
        rotate([0,0,-30]) frame(txt);
        // Extrusion sides
        translate([-16.5,11.25+1,extrusion/2]) rotate([90,0,180]) beam(width-2);
        translate([-16.5,11.25+1,extrusion/2 + 30]) rotate([90,0,180]) beam(width-2);
        // Print surface standoffs
        translate([-24,width/2+11.25-120/2,45]) rbox([30,120,6], 3, true);
        translate([-24,width/2+11.25-70/2,45]) rbox([9.5,70,11], 2, true);
        // Extruder motor?
        if (txt == "Y") {
            box_depth=12;
            translate([-24-box_depth-$o,60,40]) rotate([0,90,0]) difference() {
                rbox([35,70,box_depth], 3, true);
                translate([27,45,3]) rotate([180,0,-90]) linear_extrude(height=5) text("E", size=20);
            }
        }
    }
}

rotate([0,0,-30]) translate([0,0,-5]) union() {
    translate([-cntr,-(width+22.5)/2,-(45+6)])  {
        union() {
            side(txt="X");
            translate([0,width + 22.5,0]) rotate([0,0,-120]) side(txt="Z");
            translate([(width+22.5)*sin(60),width/2+11.25,0]) rotate([0,0,120]) side(txt="Y");
        }
    }
    translate([0,0,]) cylinder(h=5,r=glass_r, $fn=100);
}
