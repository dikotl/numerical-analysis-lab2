package main

LUP_solve :: proc(A: matrix[$N, N]$T, b: [N]T) -> (x: [N]T) {
	LU, P := LUP_decomposition(A)
	y: [N]T

	// Forward substitution. Solve 'Ly = Pb'
	for i in 0 ..< N {
		sum: T = 0
		for k in 0 ..< i {
			sum += LU[i, k] * y[k]
		}
		// Apply permutation from 'P'. Assuming `L` has ones on main diagonal.
		y[i] = b[P[i]] - sum
	}

	// Backward substitution. Solve 'Ux = y'
	for i := N - 1; i >= 0; i -= 1 {
		sum: T = 0
		for k in (i + 1) ..< N {
			sum += LU[i, k] * x[k]
		}
		// Divide on diagonal of 'U'.
		x[i] = (y[i] - sum) / LU[i, i]
	}

	return x
}

LUP_decomposition :: proc(A: matrix[$N, N]$T) -> (LU: matrix[N, N]T, P: [N]int) {
	LU = A

	for i in 0 ..< N {
		P[i] = i
	}

	for i in 0 ..< N {
		find_pivot(&LU, &P, i)

		for j in (i + 1) ..< N {
			// Same element as in 'L' matrix.
			LU[j, i] = LU[j, i] / LU[i, i]
			for k in (i + 1) ..< N {
				// Same element as in 'U' matrix.
				LU[j, k] = LU[j, k] - LU[j, i] * LU[i, k]
			}
		}
	}

	return LU, P
}

find_pivot :: proc(LU: ^matrix[$N, N]$T, P: ^[N]int, i: int) {
	max_value: T = 0
	pivot := i

	// Find max value in `i` column.
	for k in i ..< N {
		if abs(LU[k, i]) > max_value {
			max_value = abs(LU[k, i])
			pivot = k
		}
	}

	if max_value == 0 {
		panic("invalid input")
	}

	P[i], P[pivot] = P[pivot], P[i]
	for j in 0 ..< N {
		LU[i, j], LU[pivot, j] = LU[pivot, j], LU[i, j]
	}
}
