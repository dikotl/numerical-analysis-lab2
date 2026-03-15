package main

import "core:fmt"
import "core:mem"
import "core:strings"

main :: proc() {
	defer free_all(context.temp_allocator)

	A := matrix[3, 3]f64{
		4.0, 3.0, -1.0,
		0.5, 1.0, 1.0,
		3.5, 0.0, 1.0,
	}
	b := [3]f64{16, 20, 24}

	{
		x := LU_solve(A, b)
		fmt.println(vector_to_string(x))
		fmt.println(vector_to_string(A * x), '\n')
	}
	{
		x := LUP_solve(A, b)
		fmt.println(vector_to_string(x))
		fmt.println(vector_to_string(A * x), '\n')
	}
}

matrix_to_string :: proc(
	A: matrix[$N, $M]$T,
	allocator := context.temp_allocator,
	loc := #caller_location,
) -> (
	res: string,
	err: mem.Allocator_Error,
) #optional_allocator_error {
	buf := strings.builder_make(allocator = allocator, loc = loc) or_return
	w := strings.to_writer(&buf)
	for i in 0 ..< N {
		fmt.wprintf(w, "[ %+.3f", cast(f64)A[i, 0])
		for j in 1 ..< M {
			fmt.wprintf(w, ", %+.3f", cast(f64)A[i, j])
		}
		strings.write_string(&buf, " ]")
	}
	return strings.to_string(buf), nil
}

vector_to_string :: proc(
	A: [$N]$T,
	allocator := context.temp_allocator,
	loc := #caller_location,
) -> (
	res: string,
	err: mem.Allocator_Error,
) #optional_allocator_error {
	buf := strings.builder_make(allocator = allocator, loc = loc) or_return
	w := strings.to_writer(&buf)
	fmt.wprintf(w, "[ %+.3f", cast(f64)A[0])
	for i in 1 ..< N {
		fmt.wprintf(w, ", %+.3f", cast(f64)A[i])
	}
	strings.write_string(&buf, " ]")
	return strings.to_string(buf), nil
}
