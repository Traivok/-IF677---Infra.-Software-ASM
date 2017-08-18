;;; 2.asm -- checks if the vertices form a valid triangle

;;; José R. A. Figueirôa - jraf

;;; Commentary
;; If the vertices form a valid triangle, return the type of it
	
;;; Algorithm

;; isValid(a, b, c):
;	return (a < b + c)

;; isEqual(a, b):
;	return ( (a == b) 1 0 )

;; Main:
;	int x, y, z
;
;	read(x)
;	read(y)
;	read(z)
;
;	bool valid := 0
;	valid := isValid(x, y, z)
;	if (not valid) then END
;	valid := isValid(y, x, z)
;	if (not valid) then END
;	valid := isValid(z, x, y)
;	if (not valid) then END
;
;	int counter = 0
;	counter += isEqual(x, y)
;	counter += isEqual(y, z)
;	counter += isEqual(x, z)
;
;	if (counter == 3) then echo "equilatero"
;	elif (counter == 1) then echo "isosceles"
;	else echo "escaleno"
;
;	END

;;; Code:
