package main

import (
	"fmt"
	"os"
	"unicode"
)

type TokenType int

const (
	TokenExit TokenType = iota
	TokenIntLit
	TokenSemi
	TokenOpenParen
	TokenCloseParen
	TokenIdent
	TokenLet
	TokenEq
	TokenPlus
	TokenStar
	TokenMinus
	TokenFslash
	TokenOpenCurly
	TokenCloseCurly
	TokenIf
	TokenElif
	TokenElse
)

func (t TokenType) String() string {
	switch t {
	case TokenExit:
		return "`exit`"
	case TokenIntLit:
		return "int literal"
	case TokenSemi:
		return "`;`"
	case TokenOpenParen:
		return "`(`"
	case TokenCloseParen:
		return "`)`"
	case TokenIdent:
		return "identifier"
	case TokenLet:
		return "`let`"
	case TokenEq:
		return "`=`"
	case TokenPlus:
		return "`+`"
	case TokenStar:
		return "`*`"
	case TokenMinus:
		return "`-`"
	case TokenFslash:
		return "`/`"
	case TokenOpenCurly:
		return "`{`"
	case TokenCloseCurly:
		return "`}`"
	case TokenIf:
		return "`if`"
	case TokenElif:
		return "`elif`"
	case TokenElse:
		return "`else`"
	}
	panic("invalid token type")
}

func BinPrec(tokenType TokenType) (int, bool) {
	switch tokenType {
	case TokenMinus, TokenPlus:
		return 0, true
	case TokenFslash, TokenStar:
		return 1, true
	default:
		return 0, false
	}
}

type Token struct {
	Type  TokenType
	Line  int
	Value *string
}

type Tokenizer struct {
	src   string
	index int
}

func NewTokenizer(src string) *Tokenizer {
	return &Tokenizer{
		src:   src,
		index: 0,
	}
}

func (t *Tokenizer) Tokenize() []Token {
	var tokens []Token
	var buf string
	lineCount := 1

	for t.peek(0) != nil {
		ch := *t.peek(0)

		if unicode.IsLetter(ch) {
			buf += string(t.consume())
			for t.peek(0) != nil && unicode.IsLetterOrDigit(*t.peek(0)) {
				buf += string(t.consume())
			}

			if buf == "exit" {
				tokens = append(tokens, Token{Type: TokenExit, Line: lineCount})
			} else if buf == "let" {
				tokens = append(tokens, Token{Type: TokenLet, Line: lineCount})
			} else if buf == "if" {
				tokens = append(tokens, Token{Type: TokenIf, Line: lineCount})
			} else if buf == "elif" {
				tokens = append(tokens, Token{Type: TokenElif, Line: lineCount})
			} else if buf == "else" {
				tokens = append(tokens, Token{Type: TokenElse, Line: lineCount})
			} else {
				value := buf
				tokens = append(tokens, Token{Type: TokenIdent, Line: lineCount, Value: &value})
			}
			buf = ""
		} else if unicode.IsDigit(ch) {
			buf += string(t.consume())
			for t.peek(0) != nil && unicode.IsDigit(*t.peek(0)) {
				buf += string(t.consume())
			}
			value := buf
			tokens = append(tokens, Token{Type: TokenIntLit, Line: lineCount, Value: &value})
			buf = ""
		} else if ch == '/' && t.peek(1) != nil && *t.peek(1) == '/' {
			// Single line comment
			t.consume()
			t.consume()
			for t.peek(0) != nil && *t.peek(0) != '\n' {
				t.consume()
			}
		} else if ch == '/' && t.peek(1) != nil && *t.peek(1) == '*' {
			// Multi-line comment
			t.consume()
			t.consume()
			for t.peek(0) != nil {
				if *t.peek(0) == '*' && t.peek(1) != nil && *t.peek(1) == '/' {
					break
				}
				t.consume()
			}
			if t.peek(0) != nil {
				t.consume()
			}
			if t.peek(0) != nil {
				t.consume()
			}
		} else if ch == '(' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenOpenParen, Line: lineCount})
		} else if ch == ')' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenCloseParen, Line: lineCount})
		} else if ch == ';' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenSemi, Line: lineCount})
		} else if ch == '=' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenEq, Line: lineCount})
		} else if ch == '+' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenPlus, Line: lineCount})
		} else if ch == '*' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenStar, Line: lineCount})
		} else if ch == '-' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenMinus, Line: lineCount})
		} else if ch == '/' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenFslash, Line: lineCount})
		} else if ch == '{' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenOpenCurly, Line: lineCount})
		} else if ch == '}' {
			t.consume()
			tokens = append(tokens, Token{Type: TokenCloseCurly, Line: lineCount})
		} else if ch == '\n' {
			t.consume()
			lineCount++
		} else if unicode.IsSpace(ch) {
			t.consume()
		} else {
			fmt.Fprintf(os.Stderr, "Invalid token\n")
			os.Exit(1)
		}
	}

	t.index = 0
	return tokens
}

func (t *Tokenizer) peek(offset int) *rune {
	if t.index+offset >= len(t.src) {
		return nil
	}
	ch := rune(t.src[t.index+offset])
	return &ch
}

func (t *Tokenizer) consume() rune {
	ch := rune(t.src[t.index])
	t.index++
	return ch
}