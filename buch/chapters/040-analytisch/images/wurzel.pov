//
// 3dimage.pov -- -template for 3d images rendered by Povray
//
// (c) 2023 Prof Dr Andreas Müller
//
#include "../../../common/common.inc"
#include "functions.inc"

#declare flaechenfarbe = rgb<0.6,0.8,0.8>;
#declare schnittfarbe = rgb<0.6,0.6,2.0>;
#declare patchfarbe = rgb<0.8,0.2,0.4>;
#declare kurvemax = 1.80 * pi;
#declare kurveradius = 0.6;
#declare patchradius = 0.25;

place_camera(<60 * cos(-0.4), 20, 60 * sin(-0.4)>, <0, 0.525, 0>, 16/9, 0.0264)
lightsource(<10, 50, -40>, 1, White)

arrow(-1.1 * e1, 1.1 * e1, 0.01, White)
//arrow(-0.5 * e2, 0.5 * e2, 0.01, White)
arrow(-1.1 * e3, 1.1 * e3, 0.01, White)

#declare stretch = function(X) {
	select(X, -pow(abs(X), 0.7), pow(abs(X), 0.7))
}

#declare A = 1;
#declare h = function(r, phi) {
	A * (1 - exp(-10*r)) * stretch(cos(phi/2))
}

#macro flaeche(r, phi)
< r * cos(phi), 0.2 * h(r, phi), r * sin(phi)>
#end


#declare R = function(r, phi, r1, phi1) {
	sqrt(r*r + r1*r1 - 2*r*r1*cos(phi1))
}
#declare PHI = function(r, phi, r1, phi1) {
	phi + asin(sin(phi1) * r1 / R(r, phi, r1, phi1))
}

//
// Makro zur Berechnung von Punkten auf der Kreisfläche
//
#macro kreisflaeche(r, phi, r1, phi1)
	flaeche(R(r, phi, r1, phi1), PHI(r, phi, r1, phi1))
#end

//
// Kreisfläche für die Konstruktion der analytischen Fortsetzung
//
#macro kreispatch(r, phi, rad, farbe)
#local delta = <0, 0.002, 0>;
#local phi1max = 2 * pi;
#local phi1steps = 144;
#local phi1step = phi1max / phi1steps;
#local r1max = rad;
#local r1step = r1max / 10;
union {
	#local r1 = 0;
	#local phi1 = 0;
	#while (phi1 < 2 * pi - phi1step/2)
		triangle {
			kreisflaeche(r, phi, 0, phi1) + delta,
			kreisflaeche(r, phi, r1step, phi1) + delta,
			kreisflaeche(r, phi, r1step, phi1 + phi1step) + delta
		}
		#local phi1 = phi1 + phi1step;
	#end
	#local r1 = r1step;
	#while (r1 < r1max - r1step/2)
		#local phi1 = 0;
		#while (phi1 < 2 * pi - phi1step/2)
			triangle {
				kreisflaeche(r, phi,
					r1, phi1) + delta,
				kreisflaeche(r, phi,
					r1 + r1step, phi1) + delta,
				kreisflaeche(r, phi,
					r1 + r1step, phi1 + phi1step) + delta
			}
			triangle {
				kreisflaeche(r, phi,
					r1, phi1) + delta,
				kreisflaeche(r, phi,
					r1, phi1 + phi1step) + delta,
				kreisflaeche(r, phi,
					r1 + r1step, phi1 + phi1step) + delta
			}
			#local phi1 = phi1 + phi1step;
		#end
		#local r1 = r1 + r1step;
	#end
	pigment {
		color 0.5 * (farbe + White)
	}
	finish {
		metallic
		specular 0.99
	}
}
union {
	#local kreisrand = 0.006;
	sphere { flaeche(r, phi), 2 * kreisrand }
	#local phi1 = 0;
	#while (phi1 < 2*pi - phi1step/2)
		sphere { kreisflaeche(r, phi, r1max, phi1), kreisrand }
		cylinder {
			kreisflaeche(r, phi, r1max, phi1),
			kreisflaeche(r, phi, r1max, phi1 + phi1step),
			kreisrand
		}
		#local phi1 = phi1 + phi1step;
	#end
	pigment {
		color farbe
	}
	finish {
		metallic
		specular 0.99
	}
}
#end

#declare wegfarbe = Yellow;

//
// Kurve in der Fläche, entlang der die analytische Fortsetzung
// berechnet wird
//
#macro flaechenkurve()
union {
	#local wegradius = 0.008;
	#local phi = 0;
	#local phimax = kurvemax;
	#local phisteps = 288;
	#local phistep = phimax / phisteps;
	#local r = kurveradius;
	#local p = flaeche(r, phi);
	sphere { p, wegradius }
	#while (phi < phimax - phistep/2)
		#local phi = phi + phistep;
		#local pnew = flaeche(r, phi);
		cylinder { p, pnew, wegradius }
		#local p = pnew;
		sphere { p, wegradius }
	#end
	pigment {
		color wegfarbe
	}
	finish {
		metallic
		specular 0.99
	}
}
#end

//
// Kreisgebiete entlang der analytischen Fortsetzung
//
#macro flaechenanalytisch()
	#local phisteps = 18;
	#local phimin = 0;
	#local phimax = kurvemax;
	#local phistep = (phimax - phimin) / phisteps;
	#local phi = phimin;
	#while (phi < phimax + phistep/2)
		kreispatch(kurveradius, phi, patchradius, patchfarbe)
		#local phi = phi + phistep;
	#end
#end

//
// Flaechenobjekt für die Riemann-Fläche
//
#macro flaechenobjekt()
union {
#local rmin = 0;
#local rmax = 1;
#local rsteps = 100;
#local rstep = (rmax - rmin) / rsteps;
#local phimin = 0;
#local phimax = 4*pi;
#local phisteps = 1440;
#local phistep = (phimax - phimin) / phisteps;
#local phi = phimin;
#while (phi < phimax - phistep/2)
	#local r = rmin;
	#while (r < rmax - rstep/2)
		triangle {
			flaeche(r, phi),
			flaeche(r + rstep, phi + phistep),
			flaeche(r        , phi + phistep)
		}
		triangle {
			flaeche(r, phi),
			flaeche(r + rstep, phi),
			flaeche(r + rstep, phi + phistep)
		}
		#local r = r + rstep;
	#end
	#local phi = phi + phistep;
#end
	pigment {
		color flaechenfarbe
	}
	finish {
		metallic
		specular 0.99
	}
}
#end

union {
//	lightsource(flaeche(0.7,      0.625  * pi) + <0, -0.1, 0>,
//		1, 0.25 * White)
//	lightsource(flaeche(0.7,      0.375  * pi) + <0, -0.1, 0>,
//		1, 0.25 * White)
//	lightsource(flaeche(0.7,      0.125  * pi) + <0, -0.1, 0>,
//		1, 0.25 * White)
//	lightsource(flaeche(0.7, (4 - 0.125) * pi) + <0, -0.1, 0>,
//		1, 0.25 * White)
//	lightsource(flaeche(0.7, (4 - 0.375) * pi) + <0, -0.1, 0>,
//		1, 0.25 * White)
//	lightsource(flaeche(0.7, (4 - 0.625) * pi) + <0, -0.1, 0>,
//		1, 0.25 * White)
	flaechenobjekt()
	flaechenkurve()
	flaechenanalytisch()
	translate <0, 1, 0>
}

#undef h
#declare h = function(r, phi) { 0 }

lightsource(<0, 0.9, 0>, 1, 0.3 * White)

cylinder { <0, -0.001, 0>, <0, 0, 0>, 1 
	pigment {
		color flaechenfarbe
	}
	finish {
		metallic
		specular 0.99
	}
}
flaechenkurve()
flaechenanalytisch()

intersection {
	cylinder {
		flaeche(kurveradius, 0),
		flaeche(kurveradius, 0) + < 0, 0.003, 0>,
		patchradius
	}
	cylinder {
		flaeche(kurveradius, kurvemax),
		flaeche(kurveradius, kurvemax) + < 0, 0.0031, 0>,
		patchradius
	}
	pigment {
		color schnittfarbe
	}
	finish {
		metallic
		specular 0.99
	}
}

