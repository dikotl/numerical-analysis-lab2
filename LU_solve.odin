package main

LU_solve :: proc(A: matrix[$N, N]$T, b: [N]T) -> [N]T {
	L, U := LU_decomposition(A)
	x: [N]T
	y: [N]T

	// Forward substitution.
	for i in 0 ..< N {
		sum: T = 0
		for k in 0 ..< i {
			sum += L[i, k] * y[k]
		}
		y[i] = (b[i] - sum) / L[i, i]
	}

	// Backward substitution.
	for i := N - 1; i >= 0; i -= 1 {
		sum: T = 0
		for k in (i + 1) ..< N {
			sum += U[i, k] * x[k]
		}
		x[i] = (y[i] - sum) / U[i, i]
	}

	return x
}

LU_decomposition :: proc(A: matrix[$N, N]$T) -> (L: matrix[N, N]T, U: matrix[N, N]T) {
	// Initialize L matrix to identity.
	L = 1

	for i in 0 ..< N {
		// U row.
		for j in i ..< N {
			sum: T = 0
			for k in 0 ..< i {
				sum += L[i, k] * U[k, j]
			}
			U[i, j] = A[i, j] - sum
		}

		// L column.
		for j in (i + 1) ..< N {
			sum: T = 0
			for k in 0 ..< i {
				sum += L[j, k] * U[k, i]
			}
			// Just to be sure.
			if U[i, i] != 0 {
				L[j, i] = (A[j, i] - sum) / U[i, i]
			}
		}
	}
	return L, U
}
