module hex_decoder(c, display);
input [3:0] C;
output [6:0] display;

	assign display[0] = m1 & m11 & m13;
	assign display[1] = m5 & m6 & m11 & m12 & m14 & m15;
	assign display[2] = m2 & m4 & m12 & m14 & m15;
	assign display[3] =	m1 & m4 & m7 & m9 & m10 & m15;
	assign display[4] =	m1 & m3 & m4 & m5 & m7 & m9;
	assign display[5] =	m1 & m2 & m3 & m7 & m13;
	assign display[6] =	m0 & m1 & m7 & m12;