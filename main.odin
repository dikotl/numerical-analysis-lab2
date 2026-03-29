package main

import "core:bufio"
import "core:fmt"
import "core:io"
import "core:mem"
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
		fmt.print("Select matrix size:\n  1. 2x2\n  2. 3x3\n  3. 4x4\n  4. Example\n  0. Exit\n> ")
		ok: bool
		choice, ok = read_choice(&r)
		if ok {
			switch choice {
			case 0:
				return
			case 1:
				solve(&r, 2)
			case 2:
				solve(&r, 3)
			case 3:
				solve(&r, 4)
			case 4:
				A := matrix[3, 3]f64{
					4.0, 3.0, -1.0,
					0.5, 1.0, 1.0,
					3.5, 0.0, 1.0,
				}
				b := [3]f64{16, 20, 24}
				if x, has_solution := LUP_solve(A, b); has_solution {
					fmt.printfln("Found: %s", vector_to_string(x))
				} else {
					fmt.println("System has no solution")
				}
			case:
				fmt.eprintfln("error: unknown option")
				continue loop
			}
			break loop
		} else {
			fmt.eprintln("error: invalid input")
		}
	}
}

solve :: proc(r: ^bufio.Reader, $N: int) {
	A := read_matrix(r, matrix[N, N]f64)
	b := read_vector(r, N, "vector 'b'")
	if x, has_solution := LUP_solve(A, b); has_solution {
		fmt.printfln("Found: %s", vector_to_string(x))
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
		strings.write_string(&buf, " ]\n")
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
