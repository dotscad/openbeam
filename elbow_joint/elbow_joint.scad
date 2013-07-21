/**
 * elbow_joint.scad
 *
 * A variable elbow-joint for [OpenBeam](http://openbeamusa.com/).  Print and hook the
 * pieces together with an M6 bolt/nut.  I will eventually include a link to an M6 knob.
 *
 * This is a work in progress and has not yet been printed/tested, which means that some
 * measurements are likely to be wrong.
 *
 * @copyright  Chris Petersen, 2013
 * @license    http://creativecommons.org/licenses/by-sa/3.0/
 *
 * @see        http://www.thingiverse.com/thing:109467
 * @source     https://github.com/dotscad/openbeam/blob/master/elbow_joint/elbow_joint.scad
 *
 * This openSCAD library is part of the [dotscad](https://github.com/dotscad/dotscad)
 * project.
 */

module elbow_joint(nut=true, len=25, $fn=50) {
	o=.5;
	difference() {
		union() {
			cylinder(r=9.5, h=9.5);
			translate([0,-9.5,0]) cube([len,19,9.5]);
			translate([len-19,-9.5,0]) difference() {
				cube([19+20,19,19]);
				// @todo Use a polygon so this angle will always match minumum angl which len will allow
				translate([-o,-o,-o]) rotate([0,0,45]) cube([19*sqrt(2)+2*o,19+2*o,19+2*o]);
			}
		}
		// openbeam cutout
		translate([2+len-15,-7.5,2]) difference() {
			difference() {
				cube([15+20,15,15]);
				translate([0,7.5-1.5,-o]) cube([20+15,3,1+o]);
				translate([0,7.5-1.5,15-1+o]) cube([20+15,3,1+o]);
				translate([0,15-1+o,7.5-1.5]) cube([20+15,1+o,3]);
				translate([0,-o,7.5-1.5]) cube([20+15,1+o,3]);
			}
			translate([-o,-o,-o]) rotate([0,0,45]) cube([15*sqrt(2)+2*o,15+2*o,15+2*o]);
		}
		// hex nut hole
		if (nut) translate([0,0,-o]) cylinder(r=5,h=5.2+o,$fn=6);
		// pivot screw hole
		translate([0,0,-o]) cylinder(r=3, h=19+2*o);
		// openbeam screw holes
		// @todo allow inset screws
		translate([len+10,0,-o]) cylinder(r=1.5, h=19+2*o);
		translate([len+10,9.5+o,9.5]) rotate([90,0,0]) cylinder(r=1.5, h=19+2*o);
	}
}

rotate([0,00,0]) {
	// One with the nut hole for the bottom
	elbow_joint(nut=true);
	// One without
	translate([0,25,0]) elbow_joint(nut=false);
}
