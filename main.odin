package main

import "core:bufio"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	defer free_all(context.temp_allocator)

	// Initialize stdin reader.
	r: bufio.Reader
	bufio.reader_init(&r, io.to_reader(os.to_stream(os.stdin)))
	defer bufio.reader_destroy(&r)

	choice: int
	loop: for {
		fmt.print(
			"Select an option:\n" +
			"  1. Solve 2x2 system\n" +
			"  2. Solve 3x3 system\n" +
			"  3. Solve 4x4 system\n" +
			"  4. Solve system from example\n" +
			"  0. Exit\n" +
			"> ",
		)
		ok: bool
		choice, ok = read_choice(&r)
		if ok {
			switch choice {
			case 0:
				break loop
			case 1:
				A := read_matrix(&r, matrix[2, 2]f64)
				b := read_vector(&r, 2, "vector 'b'")
				solve(A, b)
			case 2:
				A := read_matrix(&r, matrix[3, 3]f64)
				b := read_vector(&r, 3, "vector 'b'")
				solve(A, b)
			case 3:
				A := read_matrix(&r, matrix[4, 4]f64)
				b := read_vector(&r, 4, "vector 'b'")
				solve(A, b)
			case 4:
				fmt.println(
					"Example System:" +
					"  4x + 3y - z = 16" +
					"  0.5x + y + z = 20" +
					"  3.5x + z = 24",
				)
				A := matrix[3, 3]f64{
					4.0, 3.0, -1.0,
					0.5, 1.0, 1.0,
					3.5, 0.0, 1.0,
				}
				b := [3]f64{16, 20, 24}
				solve(A, b)
			case:
				fmt.eprintfln("error: unknown option")
				continue loop
			}
			fmt.println()
		} else {
			fmt.eprintln("error: invalid input")
		}
	}
}

print_system :: proc(A: matrix[$N, N]$T, x: [N]T, b: [N]T) {
	buf := strings.builder_make()

	for i in 0 ..< N {
		strings.write_string(&buf, "  ")
		first := true

		for j in 0 ..< N {
			if A[i, j] != 0 {
				if first {
					fmt.sbprintf(&buf, "%g", A[i, j])
				} else if A[i, j] < 0 {
					fmt.sbprintf(&buf, " - %g", -A[i, j])
				} else {
					fmt.sbprintf(&buf, " + %g", A[i, j])
				}

				if x[j] != 1 {
					if x[j] < 0 {
						fmt.sbprintf(&buf, "*(%g)", x[j])
					} else {
						fmt.sbprintf(&buf, "*%g", x[j])
					}
				}

				first = false
			}
		}
		if first do strings.write_string(&buf, "0")
		fmt.sbprintfln(&buf, " = %g", b[i])
	}

	fmt.println(strings.to_string(buf))
}

solve :: proc(A: matrix[$N, N]$T, b: [N]T) {
	if x, has_solution := LUP_solve(A, b); has_solution {
		fmt.printfln("Found: %v", x)
		print_system(A, x, A * x)
	} else {
		fmt.println("System has no solution")
	}
}

read_choice :: proc(r: ^bufio.Reader) -> (choice: int, ok: bool) {
	line := read_line(r) or_else panic("io error")
	return strconv.parse_int(line)
}

read_vector :: proc(r: ^bufio.Reader, $N: int, what: string) -> (result: [N]f64) where N > 0 {
	loop: for {
		fmt.printf("Input %s: ", what)
		line := bufio.reader_read_string(r, '\n') or_else panic("io error")
		elements := split_space(line)
		defer delete(elements)

		if len(elements) != N {
			fmt.println("error: invalid elements count")
			continue
		}

		for element, i in elements {
			result[i] = strconv.parse_f64(element) or_continue loop
		}

		return
	}
}

read_matrix :: proc(r: ^bufio.Reader, $T: typeid/matrix[$N, N]f64) -> T where N > 0 {
	A: T = 1
	for i in 0 ..< N {
		for x, j in read_vector(r, N, fmt.tprintf("row #%d", i)) {
			A[i, j] = x
		}
	}
	return A
}

read_line :: proc(r: ^bufio.Reader) -> (line: string, err: io.Error) {
	line = bufio.reader_read_string(r, '\n') or_return
	line = strings.trim_space(line)
	return
}

split_space :: proc(s: string) -> [dynamic]string {
	s := strings.trim_space(s)
	items := make([dynamic]string)
	for {
		i := strings.index_proc(s, strings.is_space)
		if i < 0 do break
		append(&items, s[:i])
		s = s[i:]
		i = strings.index_proc(s, proc(r: rune) -> bool {return !strings.is_space(r)})
		s = s[i:]
	}
	append(&items, s)
	return items
}
