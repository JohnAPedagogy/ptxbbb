package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Incorrect usage. Correct usage is...\n")
		fmt.Fprintf(os.Stderr, "hydro <input.hy>\n")
		os.Exit(1)
	}

	var contents string
	{
		file, err := os.Open(os.Args[1])
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error opening file: %v\n", err)
			os.Exit(1)
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			contents += scanner.Text() + "\n"
		}
		if err := scanner.Err(); err != nil {
			fmt.Fprintf(os.Stderr, "Error reading file: %v\n", err)
			os.Exit(1)
		}
	}

	tokenizer := NewTokenizer(contents)
	tokens := tokenizer.Tokenize()

	parser := NewParser(tokens)
	prog, ok := parser.ParseProg()

	if !ok {
		fmt.Fprintf(os.Stderr, "Invalid program\n")
		os.Exit(1)
	}

	{
		generator := NewGenerator(prog)
		file, err := os.Create("out.asm")
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error creating output file: %v\n", err)
			os.Exit(1)
		}
		defer file.Close()

		_, err = file.WriteString(generator.GenProg())
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error writing to output file: %v\n", err)
			os.Exit(1)
		}
	}

	cmd1 := exec.Command("nasm", "-felf64", "out.asm")
	err := cmd1.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error running nasm: %v\n", err)
		os.Exit(1)
	}

	cmd2 := exec.Command("ld", "-o", "out", "out.o")
	err = cmd2.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error running ld: %v\n", err)
		os.Exit(1)
	}
}