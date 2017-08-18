;;; 2.asm -- checks if the vertices form a valid triangle

;;; José R. A. Figueirôa - jraf
	
;;; Algorithm:

;; isValid(a, b, c):
;	return (a < b + c)

;; isEqual(a, b):
;	return (a == b) (int 1) (int 0)

;; QUIT: echo "nao forma triangulo" then EXIT

;; Main:
;	int x, y, z
;
;	x := read(x) // reserva e atribui
;	y := read(y)
;	z := read(z)
;
;	bool valid := false
;	valid := isValid(x, y, z)
;	if (not valid) then QUIT
;	valid := isValid(y, x, z)
;	if (not valid) then QUIT
;	valid := isValid(z, x, y)
;	if (not valid) then QUIT
;
;	int counter = 0
;	counter += isEqual(x, y)
;	counter += isEqual(y, z)
;	counter += isEqual(x, z)
;
;	if (counter == 3) then echo "equilatero"
;	elif (counter == 1) then echo "isosceles"
;	elif (counter == 0) echo "escaleno"
;	else echo "error"
;
;	END

;;; Code: