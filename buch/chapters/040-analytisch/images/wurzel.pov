//
// 3dimage.pov -- -template for 3d images rendered by Povray
//
// (c) 2023 Prof Dr Andreas Müller
//
#include "../../../common/common.inc"
#include "functions.inc"

#declare flaechenfarbe = rgb<0.6,0.8,0.8>;

place_camera(<60 * cos(-0.4), 20, 60 * sin(-0.4)>, <0, 0, 0>, 16/9, 0.02)
lightsource(<10, 50, -40>, 1, White)

arrow(-1.2 * e1, 1.2 * e1, 0.01, White)
arrow(-0.5 * e2, 0.5 * e2, 0.01, White)
arrow(-1.2 * e3, 1.2 * e3, 0.01, White)

#declare stretch = function(X) { select(X, -pow(abs(X), 0.7), pow(abs(X), 0.7)) }

#declare h = function(r, phi) { (1 - exp(-10*r)) * stretch(cos(phi/2)) }

#macro flaeche(r, phi)
< r * cos(phi), 0.2 * h(r, phi), r * sin(phi)>
#end

lightsource(flaeche(0.7,      0.625  * pi) + <0, -0.1, 0>, 1, 0.25 * White)
lightsource(flaeche(0.7,      0.375  * pi) + <0, -0.1, 0>, 1, 0.25 * White)
lightsource(flaeche(0.7,      0.125  * pi) + <0, -0.1, 0>, 1, 0.25 * White)
lightsource(flaeche(0.7, (4 - 0.125) * pi) + <0, -0.1, 0>, 1, 0.25 * White)
lightsource(flaeche(0.7, (4 - 0.375) * pi) + <0, -0.1, 0>, 1, 0.25 * White)
lightsource(flaeche(0.7, (4 - 0.625) * pi) + <0, -0.1, 0>, 1, 0.25 * White)

#declare R = function(r, phi, r1, phi1) { sqrt(r*r + r1*r1 - 2*r*r1*cos(phi1)) }
#declare PHI = function(r, phi, r1, phi1) { phi + asin(sin(phi1) * r1 / R(r, phi, r1, phi1)) }

#macro kreisflaeche(r, phi, r1, phi1)
	flaeche(R(r, phi, r1, phi1), PHI(r, phi, r1, phi1))
#end

#macro kreispatch(r, phi, rad, farbe)
#declare delta = <0, 0.002, 0>;
#declare phi1max = 2 * pi;
#declare phi1steps = 144;
#declare phi1step = phi1max / phi1steps;
#declare r1max = rad;
#declare r1step = r1max / 10;
union {
	#declare r1 = 0;
	#declare phi1 = 0;
	#while (phi1 < 2 * pi - phi1step/2)
		triangle {
			kreisflaeche(r, phi, 0, phi1) + delta,
			kreisflaeche(r, phi, r1step, phi1) + delta,
			kreisflaeche(r, phi, r1step, phi1 + phi1step) + delta
		}
		#declare phi1 = phi1 + phi1step;
	#end
	#declare r1 = r1step;
	#while (r1 < r1max - r1step/2)
		#declare phi1 = 0;
		#while (phi1 < 2 * pi - phi1step/2)
			triangle {
				kreisflaeche(r, phi, r1, phi1) + delta,
				kreisflaeche(r, phi, r1 + r1step, phi1) + delta,
				kreisflaeche(r, phi, r1 + r1step, phi1 + phi1step) + delta
			}
			triangle {
				kreisflaeche(r, phi, r1, phi1) + delta,
				kreisflaeche(r, phi, r1, phi1 + phi1step) + delta,
				kreisflaeche(r, phi, r1 + r1step, phi1 + phi1step) + delta
			}
			#declare phi1 = phi1 + phi1step;
		#end
		#declare r1 = r1 + r1step;
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
	#declare kreisrand = 0.006;
	sphere { flaeche(r, phi), 2 * kreisrand }
	#declare phi1 = 0;
	#while (phi1 < 2*pi - phi1step/2)
		sphere { kreisflaeche(r, phi, r1max, phi1), kreisrand }
		cylinder {
			kreisflaeche(r, phi, r1max, phi1),
			kreisflaeche(r, phi, r1max, phi1 + phi1step),
			kreisrand
		}
		#declare phi1 = phi1 + phi1step;
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

//kreispatch(0.7, 0.9*pi, 0.25, rgb<0.8,0,0>)

#declare wegfarbe = Yellow;

union {
	#declare wegradius = 0.008;
	#declare phi = 0;
	#declare phimax = 2.25 * pi;
	#declare phisteps = 288;
	#declare phistep = phimax / phisteps;
	#declare r = 0.6;
	#declare p = flaeche(r, phi);
	sphere { p, wegradius }
	#while (phi < phimax - phistep/2)
		#declare phi = phi + phistep;
		#declare pnew = flaeche(r, phi);
		cylinder { p, pnew, wegradius }
		#declare p = pnew;
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

#declare phisteps = 20;
#declare phimin = 0;
#declare phimax = 2.25 * pi;
#declare phistep = (phimax - phimin) / phisteps;
#declare phi = phimin;
#while (phi < phimax + phistep/2)
	kreispatch(0.6, phi, 0.25, rgb<0.8,0,0>)
	#declare phi = phi + phistep;
#end

union {
#declare rmin = 0;
#declare rmax = 1;
#declare rsteps = 100;
#declare rstep = (rmax - rmin) / rsteps;
#declare phimin = 0;
#declare phimax = 4*pi;
#declare phisteps = 1440;
#declare phistep = (phimax - phimin) / phisteps;
#declare phi = phimin;
#while (phi < phimax - phistep/2)
	#declare r = rmin;
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
		#declare r = r + rstep;
	#end
	#declare phi = phi + phistep;
#end
	pigment {
		color flaechenfarbe
	}
	finish {
		metallic
		specular 0.99
	}
}


